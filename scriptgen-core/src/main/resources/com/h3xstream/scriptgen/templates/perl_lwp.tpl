use LWP::UserAgent;
use HTTP::Request::Common;
<#if util.atLeastOneCookie(requests)>
use HTTP::Cookies;
</#if>

<#list requests as req>
my $url = URI->new("${util.perlStr(req.url)}");
<#if req.parametersGet??>
$url->query_form(${util.perlMap(req.parametersGet)});
</#if>

<#if req.cookies??>
my $cookies = HTTP::Cookies->new();
<#list req.cookies?keys as c>
$cookies->set_cookie(0,"${util.perlStr(c)}", "${util.perlStr(req.cookies[c])}","/","${util.perlStr(req.hostname)}");
</#list>

</#if>
my $ua = LWP::UserAgent->new();
<#if req.cookies??>
$ua->cookie_jar($cookies);
</#if>
<#if req.basicAuth??>
$ua->credentials("${util.perlStr(req.hostname)}", "realm-name", '${util.perlStr(req.basicAuth.username)}', '${util.perlStr(req.basicAuth.password)}');
</#if>
<#if req.ssl && settings.disableSsl>
$ua->ssl_opts( verify_hostnames => 0 );
</#if>
<#if settings.proxy>
$ua->proxy(['http'], 'http://127.0.0.1:8080/');
</#if>

<#if req.parametersMultipart??>
@multipartParams = ${util.perlMergePostMultipart(req.parametersPost,req.parametersMultipart)};
my $req = POST $url, Content_Type=>'form-data', Content=> @multipartParams;
<#elseif req.parametersPost??>
my $req = POST $url<#if req.parametersPost??>, ${util.perlMap(req.parametersPost)}</#if>;
<#else>
my $req = ${util.perlStr(req.method?upper_case)} $url;
</#if>
<#if req.headers??>
<#list req.headers?keys as h>
$req->header("${util.perlStr(h)}" => "${util.perlStr(req.headers[h])}");
</#list>
</#if>
<#if req.postData??>
$req->content("${util.perlStr(req.postData)}");
</#if>
my $resp = $ua->request($req);

print "Status code : ".$resp->code."\n";
print "Response body : ".$resp->content."\n";

</#list>