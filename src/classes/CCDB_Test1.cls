/**
 * Created by nagesingh on 4/2/2018.
 */

public class CCDB_Test1 {

  public static void sendFile(){

    String endpoint = 'http://ccdb.nissancommunity.com.mx';

    DateTime df = DateTime.now();
    String dateStr = df.format('ddMMyyyy_HHmm');
    String nameFile ='ln_CCDB_EncuestasRap_Vta_Servicio_'+dateStr+'.zip';
    Blob fileZip = [Select Body From Document Where Id='0157F00000179Nf' LIMIT 1].Body;

    // ENCABEZADO
    String strHeader = '--741e90d31eff\n'+
      'Content-Disposition: form-data; name="ENCUESTAS_RAPIDAS"; filename="'+nameFile+'"\n'+
      'Content-Type: application/octet-stream';

    String strHeaderEncoded = EncodingUtil.base64Encode(Blob.valueOf(strHeader+'\n\n'));
    while(strHeaderEncoded.endsWith('=')) {
      strHeader+=' ';
      strHeaderEncoded = EncodingUtil.base64Encode(Blob.valueOf(strHeader+'\n\n'));
    }

    // BODY
    String strBody = EncodingUtil.base64Encode(fileZip);
    String strFooter = '\n--741e90d31eff--';

    String strBodyEncoded = strBody;
    String strFooterEncoded = EncodingUtil.base64Encode(Blob.valueOf(strFooter));

    Blob blobBody = null;
    String last4Bytes = strBodyEncoded.substring(strBodyEncoded.length()-4,strBodyEncoded.length());

    if(last4Bytes.endsWith('=')) {
      Blob decoded4Bytes = EncodingUtil.base64Decode(last4Bytes);
      HttpRequest objHttpRequest = New HttpRequest();
      objHttpRequest.setBodyAsBlob(decoded4Bytes);
      String last4BytesFooter = objHttpRequest.getBody()+strFooter;
      blobBody = EncodingUtil.base64Decode(strHeaderEncoded+strBodyEncoded.substring(0,strBodyEncoded.length()-4)+EncodingUtil.base64Encode(Blob.valueOf(last4BytesFooter)));
    } else {
      blobBody = EncodingUtil.base64Decode(strHeaderEncoded+strBodyEncoded+strFooterEncoded);
    }

    if(blobBody.size()>3000000) {
      // throw new CustomException('File size limit is 3 MBytes');
      system.debug('File size limit is 3 MBytes');
    }else{
      system.debug('blobBody.size()'+blobBody.size());
    }

    String token = login();
    if(token==null){
      System.debug('Error trying to login into webservices');
      return;
    }
    System.debug('Token:' + token);


    uploadFile(blobBody, nameFile, endpoint);
  }

  public static String login(){

    String endpoint = 'http://ccdb.nissancommunity.com.mx';
    String usuario = 'usuarioEncuestasRapidas@nissan.com.mx';
    String pwd = 'Test123-';

    HttpRequest reqLogin = new HttpRequest();
    reqLogin.setEndpoint(endpoint + '/Seguridad/api/Seguridad/Token?usuario=' + usuario + '&password=' + pwd);
    reqLogin.setMethod('GET');
    reqLogin.setHeader('Content-Type', 'application/json; charset=utf-8');

    Http http = new Http();
    HTTPResponse resLogin = new HTTPResponse();
    try{
      resLogin = http.send(reqLogin);
      if(resLogin.getStatusCode() != 200){
        String msg = String.valueOf(resLogin.getStatusCode()) + '-' +
          resLogin.getStatus();
        return null;
      }
    }catch(System.CalloutException ce){
      System.debug(ce);
      return null;
    }catch(System.Exception e){
      System.debug(e);
      return null;
    }

    if(String.isBlank(resLogin.getBody())){
      System.debug('Empty body');
      return null;
    }

    String token = resLogin.getBody().replace('"','');
    System.debug('Token:' + token);
    return token;
  }

  public static void uploadFile(Blob file_body, String file_name, String reqEndPoint){
    String boundary = '----------------------------741e90d31eff';
    String header = '--'+boundary+'\nContent-Disposition: form-data; name="file"; filename="'+file_name+'";\nContent-Type: application/octet-stream';
    String footer = '--'+boundary+'--';
    String headerEncoded = EncodingUtil.base64Encode(Blob.valueOf(header+'\r\n\r\n'));
    while(headerEncoded.endsWith('='))
    {
      header+=' ';
      headerEncoded = EncodingUtil.base64Encode(Blob.valueOf(header+'\r\n\r\n'));
    }
    String bodyEncoded = EncodingUtil.base64Encode(file_body);

    Blob bodyBlob = null;
    String last4Bytes = bodyEncoded.substring(bodyEncoded.length()-4,bodyEncoded.length());
    if(last4Bytes.endsWith('==')) {
      last4Bytes = last4Bytes.substring(0,2) + '0K';
      bodyEncoded = bodyEncoded.substring(0,bodyEncoded.length()-4) + last4Bytes;
      String footerEncoded = EncodingUtil.base64Encode(Blob.valueOf(footer));
      bodyBlob = EncodingUtil.base64Decode(headerEncoded+bodyEncoded+footerEncoded);
    } else if(last4Bytes.endsWith('=')) {
      last4Bytes = last4Bytes.substring(0,3) + 'N';
      bodyEncoded = bodyEncoded.substring(0,bodyEncoded.length()-4) + last4Bytes;
      footer = '\n' + footer;
      String footerEncoded = EncodingUtil.base64Encode(Blob.valueOf(footer));
      bodyBlob = EncodingUtil.base64Decode(headerEncoded+bodyEncoded+footerEncoded);
    } else {
      footer = '\r\n' + footer;
      String footerEncoded = EncodingUtil.base64Encode(Blob.valueOf(footer));
      bodyBlob = EncodingUtil.base64Decode(headerEncoded+bodyEncoded+footerEncoded);
    }

    HttpRequest req = new HttpRequest();
    req.setHeader('Content-Type','multipart/form-data; boundary='+boundary);
    req.setMethod('POST');
    req.setEndpoint(reqEndPoint);
    req.setBodyAsBlob(bodyBlob);
    req.setTimeout(120000);

    Http http = new Http();
    HTTPResponse res = http.send(req);
    System.debug('Response:' + res.getBody());
    System.debug(res.getStatus());
    System.debug(res.getStatusCode());
    System.debug(res);
  }
}