import Foundation

enum AdSkip {
    static let script = """
    (function() {
        if (location.hostname.indexOf('aiyifan') === -1) return;

        // ━━ 1. KILL AD TIMER ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
        // RxJS timer(20000,50000) → setInterval(flush, 20000/50000).
        var _si = window.setInterval;
        window.setInterval = function(fn, ms) {
            if (typeof ms === 'number' && ms >= 15000 && ms <= 55000) return 0;
            return _si.apply(window, arguments);
        };

        // ━━ 2. BLOCK video.load() DURING AD BREAKS ━━━━━━━━━━━━━━
        var adBreak = false;
        var adBreakTimer = 0;
        var mainVideo = null;

        var _load = HTMLMediaElement.prototype.load;
        HTMLMediaElement.prototype.load = function() {
            if (adBreak && mainVideo && this === mainVideo) return;
            return _load.call(this);
        };

        function findMain() {
            if (mainVideo && mainVideo.isConnected) return;
            mainVideo = null;
            var v = document.querySelectorAll('video');
            for (var i = 0; i < v.length; i++) {
                if (v[i].duration > 60) { mainVideo = v[i]; return; }
            }
        }

        var adBlockCss = document.createElement('style');
        adBlockCss.id = 'adskip-block';

        function startAdBreak() {
            findMain();
            adBreak = true;
            clearTimeout(adBreakTimer);
            adBreakTimer = setTimeout(endAdBreak, 25000);
            adBlockCss.textContent =
                'div[style*=\"z-index\"]{pointer-events:none!important;opacity:0!important}' +
                '.cdk-overlay-container{pointer-events:none!important;visibility:hidden!important}';
            (document.head || document.documentElement).appendChild(adBlockCss);
            hideOverlays();
            setTimeout(hideOverlays, 200);
            setTimeout(hideOverlays, 600);
            setTimeout(hideOverlays, 1500);
            setTimeout(hideOverlays, 5000);
        }

        function endAdBreak() {
            adBreak = false;
            clearTimeout(adBreakTimer);
            adBlockCss.textContent = '';
        }

        // ━━ 3. TRACK AD STATE ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
        window.addEventListener('startads', startAdBreak);
        window.addEventListener('endads', endAdBreak);

        // ━━ 4. HIDE AD OVERLAYS ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
        function hideOverlays() {
            if (!document.body) return;
            var divs = document.querySelectorAll('div');
            for (var i = divs.length - 1; i >= 0; i--) {
                try {
                    var cs = getComputedStyle(divs[i]);
                    var pos = cs.position;
                    if (pos !== 'fixed' && pos !== 'absolute') continue;
                    if (parseInt(cs.zIndex || 0) < 50) continue;
                    var t = divs[i].innerText || '';
                    if (t.indexOf('\\u540e\\u64ad\\u653e\\u5e7f\\u544a') !== -1 ||
                        t.indexOf('\\u6682\\u65f6\\u65e0\\u6cd5\\u663e\\u793a\\u5e7f\\u544a') !== -1 ||
                        t.indexOf('\\u8df3\\u8fc7\\u5e7f\\u544a') !== -1 ||
                        t.indexOf('\\u8bf7\\u8f93\\u5165\\u90ae\\u7bb1') !== -1 ||
                        t.indexOf('\\u624b\\u673a\\u53f7\\u767b\\u5f55') !== -1) {
                        divs[i].style.setProperty('display', 'none', 'important');
                    }
                } catch(e) {}
            }
            var logins = document.querySelectorAll('app-dropdown-login-request');
            for (var j = 0; j < logins.length; j++) {
                logins[j].style.setProperty('display', 'none', 'important');
            }
            if (mainVideo && mainVideo.paused) {
                mainVideo.play().catch(function(){});
            }
        }

        // ━━ 5. MUTATION OBSERVER: catch overlays the events miss ━
        function scan() {
            if (!document.body) return;
            findMain();
            var text = document.body.innerText || '';
            var hasOverlay =
                text.indexOf('\\u540e\\u64ad\\u653e\\u5e7f\\u544a') !== -1 ||
                text.indexOf('\\u6682\\u65f6\\u65e0\\u6cd5\\u663e\\u793a\\u5e7f\\u544a') !== -1;
            var hasLogin =
                text.indexOf('\\u8bf7\\u8f93\\u5165\\u90ae\\u7bb1') !== -1 &&
                text.indexOf('\\u624b\\u673a\\u53f7\\u767b\\u5f55') !== -1;
            if (hasOverlay || hasLogin) {
                startAdBreak();
            }
        }

        function boot() {
            if (!document.body) { setTimeout(boot, 100); return; }
            new MutationObserver(scan).observe(document.body, {
                childList: true, subtree: true
            });
            _si.call(window, function() { findMain(); }, 2000);
        }
        boot();

        // ━━ 6. CSS: SIDEBAR ADS ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
        var css = document.createElement('style');
        css.textContent = [
            '.video-page-right{display:none!important}',
            '.search-page-right{display:none!important}',
            'app-ad-center{display:none!important}',
            'app-tv-banner{display:none!important}',
            'app-app-download{display:none!important}',
        ].join('');
        (document.head || document.documentElement).appendChild(css);
    })();
    """
}
