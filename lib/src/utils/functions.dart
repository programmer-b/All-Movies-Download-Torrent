import 'dart:developer';
import 'package:http/http.dart' as http;
Future<String?> getGrbdurl(String url) async {
  var body = 'qdf=1';
  var headers = {
    'Content-Type': 'application/x-www-form-urlencoded',
    'Cookie': grdcookie
  };

  var response = await http.post(Uri.parse(url), body: body, headers: headers);

  if (response.statusCode ~/ 100 == 2) {
    // Successful POST request
    var data = response.body;
    // log('DATA ${data}');
    // log(data.grdurl);
    return data;
  } else {
    // POST request failed
    log('Request failed with status: ${response.statusCode}');
  }
  return null;
}

Future<String?> getMasterurl(String url) async {
  var headers = {
    'Cookie': grdcookie,
  };
  var response = await http.get(Uri.parse(url), headers: headers);
  log('RESPONSE ${response.body}');

  if (response.statusCode ~/ 100 == 2) {
    return response.body;
  } else {
    log('request failed with status code: ${response.statusCode}');
  }
  return null;
}
const String specificDefault = "default";
Map<String, String> searchMoviesHeader = {
  "Cookie":
  "aGooz=73jn49bcget1sgjmctl6pkqqkn; d0813dbe=7baddbc1a09caeacce81ac; _555e=CCDD440DAC4E18CF3817A51864146370E99B29F7; 67e2bb18=5606022a16e07a375dd083; _1281=3A8235ECC3D78D818C0AE42734120C2DAD571563; AdskeeperStorage=%7B%220%22%3A%7B%22svspr%22%3A%22https%3A%2F%2Fwww.goojara.to%2FmwOG47%22%2C%22svsds%22%3A1%7D%2C%22C1374985%22%3A%7B%22page%22%3A1%7D%7D; 747a99a6=a06b494648f83745dbfd12; _03db=54659A7E10BAC798D61F9BB1BAECD3FB5DDBAFEB; 6de08a84=0a8454d4353e09387580ea; 0b4c70a3=fec2f2a58ce05fbbd59954",
  "Content-Type": "application/x-www-form-urlencoded",
};
String kfMoviesSearchUrl = "https://www.goojara.to/xhrr.php";
const String defaultLanguageCode = "en";
String grdcookie =
    "wooz=rfsplpsc5gk9gm9fu6trkrjh7r; utkap=dTIzda; xylay=CMhxBb; zgwtz=tZzCVk; thggn=KpOfGC; wyndr=DVFjZA; adpvd=rdGIeR; iagkh=GdArNS; umoua=LBHszh; khzfv=qjVoDk; pmllv=KSASIc; jsgzq=iFJzXx; kvkvg=cIPEet; thwcz=VMziuv; plxol=LrDZRv; odzca=zpPxyi; kjaaw=bwzeuM; fvwoa=srBfpm; ijlwu=qUvIGM; zcbgq=pxNeGy; aoycv=TWTyzx";