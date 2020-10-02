! function(e) {
  var t = {};

  function n(o) {
    if (t[o]) return t[o].exports;
    var i = t[o] = {
      i: o,
      l: !1,
      exports: {}
    };
    return e[o].call(i.exports, i, i.exports, n), i.l = !0, i.exports
  }
  n.m = e, n.c = t, n.d = function(e, t, o) {
    n.o(e, t) || Object.defineProperty(e, t, {
      enumerable: !0,
      get: o
    })
  }, n.r = function(e) {
    "undefined" != typeof Symbol && Symbol.toStringTag && Object.defineProperty(e, Symbol.toStringTag, {
      value: "Module"
    }), Object.defineProperty(e, "__esModule", {
      value: !0
    })
  }, n.t = function(e, t) {
    if (1 & t && (e = n(e)), 8 & t) return e;
    if (4 & t && "object" == typeof e && e && e.__esModule) return e;
    var o = Object.create(null);
    if (n.r(o), Object.defineProperty(o, "default", {
        enumerable: !0,
        value: e
      }), 2 & t && "string" != typeof e)
      for (var i in e) n.d(o, i, function(t) {
        return e[t]
      }.bind(null, i));
    return o
  }, n.n = function(e) {
    var t = e && e.__esModule ? function() {
      return e.default
    } : function() {
      return e
    };
    return n.d(t, "a", t), t
  }, n.o = function(e, t) {
    return Object.prototype.hasOwnProperty.call(e, t)
  }, n.p = "", n(n.s = 0)
}([function(e, t, n) {
  "use strict";
  n.r(t);
  const o = new class {
    constructor() {
      this.bridgeScheme = "fuckkit://", this.dispatchMsgPath = "dispatch_message/", this.callbackId = 1e3, this.callbackMap = {}, this.eventHookMap = {}, this.sendMessageQueue = []
    }
    _fetchQueue() {
      const e = JSON.stringify(this.sendMessageQueue);
      return this.sendMessageQueue = [], e
    }
    _dispatchUrlMsg(e) {
      if ("undefined" != typeof document) {
        const t = document.createElement("iframe");
        t.style.display = "none", document.body.appendChild(t), t.src = e, setTimeout(() => {
          document.body.removeChild(t)
        }, 300)
      }
    }
    _handleMessageFromApp(e) {
      const t = e.__params;
      let n = {
        __err_code: "cb404"
      };
      const o = e.__callback_id;
      return "string" == typeof o && "function" == typeof this.callbackMap[o] ? (n = this.callbackMap[o](t), delete this.callbackMap[o]) : "string" == typeof o && Array.isArray(this.eventHookMap[o]) && this.eventHookMap[o].forEach(e => {
        "function" == typeof e && (n = e(t))
      }), JSON.stringify(n)
    }
    _call(e, t = {}, n = null, o = 3, i = 0, s = "call") {
      if (!e || "string" != typeof e) return;
      let a;
      i ? a = e : (this.callbackId += 1, a = this.callbackId.toString()), "function" == typeof n && (this.callbackMap[a] = n);
      let r = {
        JSSDK: o,
        func: e,
        params: t,
        __msg_type: s,
        __callback_id: a
      };
      try {
        window.webkit && window.webkit.messageHandlers && window.webkit.messageHandlers.callMethodParams && "function" == typeof window.webkit.messageHandlers.callMethodParams.postMessage ? window.webkit.messageHandlers.callMethodParams.postMessage(r) : window.androidJsBridge && "function" == typeof window.androidJsBridge.callMethodParams ? window.androidJsBridge.callMethodParams(JSON.stringify(r)) : (this.sendMessageQueue.push(r), this._dispatchUrlMsg(`${this.bridgeScheme}${this.dispatchMsgPath}`))
      } catch (e) {
        console.error(e)
      }
    }
    _on(e, t, n = 3) {
      if (!e || "string" != typeof e || "function" != typeof t) return;
      this.eventHookMap[e] ? this.eventHookMap[e].push(t) : this.eventHookMap[e] = [t];
      const o = {
        JSSDK: n,
        __msg_type: "on",
        __callback_id: e,
        func: e
      };
      try {
        window.androidJsBridge && "function" == typeof window.androidJsBridge.onMethodParams ? window.androidJsBridge.onMethodParams(JSON.stringify(o)) : window.webkit && window.webkit.messageHandlers && window.webkit.messageHandlers.callMethodParams && "function" == typeof window.webkit.messageHandlers.callMethodParams.postMessage ? window.webkit.messageHandlers.callMethodParams.postMessage(o) : this._call(e, {}, null, n, 1, "on")
      } catch (e) {
        console.error(e)
      }
    }
    _off(e, t, n = 3) {
      if (e && "string" == typeof e && "function" == typeof t && this.eventHookMap[e]) {
        if (this.eventHookMap[e] = this.eventHookMap[e].filter(e => e !== t), this.eventHookMap[e].length > 0) return;
        const o = {
          JSSDK: n,
          __msg_type: "off",
          func: e
        };
        try {
          window.androidJsBridge && "function" == typeof window.androidJsBridge.offMethodParams ? window.androidJsBridge.offMethodParams(JSON.stringify(o)) : window.webkit && window.webkit.messageHandlers && window.webkit.messageHandlers.callMethodParams && "function" == typeof window.webkit.messageHandlers.callMethodParams.postMessage ? window.webkit.messageHandlers.callMethodParams.postMessage(o) : this._call(e, {}, null, n, 0, "off")
        } catch (e) {
          console.error(e)
        }
      }
    }
    _trigger(e, t) {
      const n = this.eventHookMap[e];
      let o = !1;
      if (n)
        for (let e = 0, i = n.length; e < i; e++) {
          const i = n[e];
          "function" == typeof i && (o = !0, i(t))
        }
      return o
    }
    init() {
      let e = {
        call: (...e) => this._call(...e),
        on: (...e) => this._on(...e),
        off: (...e) => this._off(...e),
        trigger: (...e) => this._trigger(...e)
      };
      return "undefined" != typeof window && (window.Native2JSBridge && window.JS2NativeBridge ? e = window.JS2NativeBridge : (window.Native2JSBridge = {
        _fetchQueue: (...e) => this._fetchQueue(...e),
        _handleMessageFromApp: (...e) => this._handleMessageFromApp(...e)
      }, window.JS2NativeBridge = e)), e
    }
  };
  t.default = o.init()
}]);