#!/usr/bin/python
# -*- coding: utf-8 -*-

# @Time    : 2020-01-15
# @Author  : lework
# @Desc    : 使用Pam-Python实现SSH的企业微信双因素认证

import sys
import pwd
import json
import string
import syslog
import random
import hashlib
import httplib
import datetime
import platform


def auth_log(msg):
    """写入日志"""
    syslog.openlog(facility=syslog.LOG_AUTH)
    syslog.syslog("MultiFactors Authentication: " + msg)
    syslog.closelog()


def action_wechat(content, touser=None, toparty=None, totag=None):
    """微信通知"""
    host = "qyapi.weixin.qq.com"

    # 企业微信设置
    corpid = ""
    secret = ""
    agentid = ""

    headers = {
        'Content-Type': 'application/json'
    }

    access_token_url = '/cgi-bin/gettoken?corpid={id}&corpsecret={crt}'.format(id=corpid, crt=secret)

    try:
        httpClient = httplib.HTTPSConnection(host, timeout=10)
        httpClient.request("GET", access_token_url, headers=headers)
        response = httpClient.getresponse()
        token = json.loads(response.read())['access_token']
        httpClient.close()
    except Exception as e:
        auth_log('get wechat token error: %s' % e)
        return False

    send_url = '/cgi-bin/message/send?access_token={token}'.format(token=token)

    data = {
        "msgtype": 'text',
        "agentid": agentid,
        "text": {'content': content},
        "safe": 0
    }

    if touser:
        data['touser'] = touser
    if toparty:
        data['toparty'] = toparty
    if toparty:
        data['totag'] = totag

    try:
        httpClient = httplib.HTTPSConnection(host, timeout=10)
        httpClient.request("POST", send_url, json.dumps(data), headers=headers)
        response = httpClient.getresponse()
        result = json.loads(response.read())
        if result['errcode'] != 0:
            auth_log('Failed to send verification code using WeChat: %s' % result)
            return False
    except Exception as e:
        auth_log('Error sending verification code using WeChat: %s' % e)
        return False
    finally:
        if httpClient:
            httpClient.close()

    auth_log('Send verification code using WeChat successfully.')
    return True

def get_user_comment(user):
    """获取用户描述信息"""
    try:
        comments = pwd.getpwnam(user).pw_gecos
    except:
        auth_log("No local user (%s) found." % user)
        comments = ''

    return comments # 返回用户描述信息


def get_hash(plain_text):
    """获取PIN码的sha512字符串"""
    key_hash = hashlib.sha512()
    key_hash.update(plain_text)

    return key_hash.digest()


def gen_key(pamh, user, length):
    """生成PIN码并发送到用户"""
    pin = ''.join(random.choice(string.digits) for i in range(length))
    #msg = pamh.Message(pamh.PAM_ERROR_MSG, "The pin is: (%s)" % (pin))  # 登陆界面输出验证码，测试目的，实际使用中注释掉即可
    #pamh.conversation(msg)

    hostname = platform.node().split('.')[0]
    content = "[MFA] %s 使用 %s 正在登录 %s, 验证码为【%s】, 1分钟内有效。" % (pamh.rhost, user, hostname, pin)
    touser = get_user_comment(user) 
    result = action_wechat(content, touser=touser)

    pin_time = datetime.datetime.now()
    return get_hash(pin), pin_time


def pam_sm_authenticate(pamh, flags, argv):
    PIN_LENGTH = 6  # PIN码长度
    PIN_LIVE = 60   # PIN存活时间,超出时间验证失败
    PIN_LIMIT = 3   # 限制错误尝试次数
    EMERGENCY_HASH = '\xba2S\x87j\xedk\xc2-Jo\xf5=\x84\x06\xc6\xad\x86A\x95\xed\x14J\xb5\xc8v!\xb6\xc23\xb5H\xba\xea\xe6\x95m\xf3F\xec\x8c\x17\xf5\xea\x10\xf3^\xe3\xcb\xc5\x14y~\xd7\xdd\xd3\x14Td\xe2\xa0\xba\xb4\x13'  # 预定义验证码123456的hash

    try:
        user = pamh.get_user()
    except pamh.exception as e:
        return e.pam_result
  
    auth_log("login_ip: %s, login_user: %s" % (pamh.rhost, user))

    if get_user_comment(user) == '':
        msg = pamh.Message(pamh.PAM_ERROR_MSG, "[Warning] You need to set the Qiyi WeChat username in the comment block for user %s." % (user))
        pamh.conversation(msg)
        return pamh.PAM_ABORT
    
    pin, pin_time = gen_key(pamh, user, PIN_LENGTH)

    for attempt in range(0, PIN_LIMIT):  # 限制错误尝试次数
        msg = pamh.Message(pamh.PAM_PROMPT_ECHO_OFF, "Verification code:")
        resp = pamh.conversation(msg)
        resp_time = datetime.datetime.now()
        input_interval = resp_time - pin_time
        if input_interval.seconds > PIN_LIVE:
            msg = pamh.Message(pamh.PAM_ERROR_MSG, "[Warning] Time limit exceeded.")
            pamh.conversation(msg)
            return pamh.PAM_ABORT
        resp_hash = get_hash(resp.resp)
        if resp_hash == pin or resp_hash == EMERGENCY_HASH:  # 用户输入与生成的验证码进行校验
            return pamh.PAM_SUCCESS
        else:
            continue

    msg = pamh.Message(pamh.PAM_ERROR_MSG, "[Warning] Too many authentication failures.")
    pamh.conversation(msg)
    return pamh.PAM_AUTH_ERR


def pam_sm_setcred(pamh, flags, argv):
    return pamh.PAM_SUCCESS


def pam_sm_acct_mgmt(pamh, flags, argv):
    return pamh.PAM_SUCCESS


def pam_sm_open_session(pamh, flags, argv):
    return pamh.PAM_SUCCESS


def pam_sm_close_session(pamh, flags, argv):
    return pamh.PAM_SUCCESS

def pam_sm_chauthtok(pamh, flags, argv):
    return pamh.PAM_SUCCESS
