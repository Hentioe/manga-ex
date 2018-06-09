// Variables: hostname, imgNameAttr here
location = {
    hostname: hostname
}
function unsuan(s) {
    sw = "hhmmoo.com|hhssee.com";
    su = location.hostname.toLowerCase();
    b = false;
    for (i = 0; i < sw.split("|").length; i++) {
        if (su.indexOf(sw.split("|")[i]) > -1) {
            b = true;
            break;
        }
    }
    if (!b) return "";

    x = s.substring(s.length - 1);
    w = "abcdefghijklmnopqrstuvwxyz";
    xi = w.indexOf(x) + 1;
    sk = s.substring(s.length - xi - 12, s.length - xi - 1);
    s = s.substring(0, s.length - xi - 12);
    k = sk.substring(0, sk.length - 1);
    f = sk.substring(sk.length - 1);
    for (i = 0; i < k.length; i++) {
        eval("s=s.replace(/" + k.substring(i, i + 1) + "/g,'" + i + "')");
    }
    ss = s.split(f);
    s = "";
    for (i = 0; i < ss.length; i++) {
        s += String.fromCharCode(ss[i]);
    }
    return s;
}

console.log(`"${unsuan(imgNameAttr)}"`)