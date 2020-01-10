import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:movie_6v/utils/http.dart';
import 'package:url_launcher/url_launcher.dart';

class MovieDetailPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // 电影详情地址
    var url = ModalRoute.of(context).settings.arguments;

    return info(url);
  }

  info(String url) {
    return FutureBuilder(
      future: HttpUtil.get(url),
      builder: (context, snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.none:
          case ConnectionState.active:
          case ConnectionState.waiting:
            return Center(
              child: CircularProgressIndicator(),
            );
            break;
          case ConnectionState.done:
            return detail(snapshot.data.toString());
            break;
          default:
            return null;
        }
      },
    );
  }

  // 电影信息
  detail(String html) {
    var title = matchTitle(html);
    var cover = matchImg(html);
    var img = matchIntroduceImg(html);
    var introduce = matchIntroduce(html);
    var downloadLinks = matchDownloadLink(html);
    var liveLinks = matchLiveUrl(html);

    return Scaffold(
      body: CustomScrollView(
        slivers: <Widget>[
          SliverAppBar(
            flexibleSpace: FlexibleSpaceBar(
              title: Text(title),
              centerTitle: true,
              background: Image.network(
                cover,
                fit: BoxFit.cover,
              ),
            ),
            floating: false,
            snap: false,
            pinned: true,
            expandedHeight: ScreenUtil.screenHeightDp / 2,
            centerTitle: true,
          ),
          SliverList(
            delegate: SliverChildListDelegate([
              Html(
                  data: introduce,
                  padding: EdgeInsets.symmetric(
                      horizontal: ScreenUtil().setWidth(30))),
              introduceImg(img),
              download(downloadLinks),
              liveGroup(liveLinks, 0),
              liveGroup(liveLinks, 1),
            ]),
          )
        ],
      ),
    );
  }

  // 简介图片
  introduceImg(String url) {
    if (url != null) {
      return CachedNetworkImage(
        imageUrl: url,
        fit: BoxFit.cover,
      );
    }
    return Container();
  }

  // 下载链接
  download(List links) {
    return Column(
      children: <Widget>[
        Divider(),
        Text(
          '下载地址',
          style: TextStyle(fontSize: ScreenUtil().setSp(50)),
        ),
        Column(
          children: links.map((link) {
            String url = link['url'];
            var type = '';
            var codeDes = '';
            if (url.startsWith('magnet')) {
              type = '磁力';
            } else if (url.startsWith('ed2k')) {
              type = '电驴';
            } else if (url.startsWith('thunder')) {
              type = '迅雷';
            } else if (url.contains('pan.baidu.com')) {
              type = '网盘';
              codeDes = '，提取码为${link['code']}';
            }

            return Padding(
              padding:
                  EdgeInsets.symmetric(horizontal: ScreenUtil().setWidth(20)),
              child: Row(
                children: <Widget>[
                  Container(
                    width: ScreenUtil().setWidth(200),
                    child: Chip(label: Text(type)),
                  ),
                  Container(
                    width:
                        ScreenUtil.screenWidthDp - ScreenUtil().setWidth(240),
                    child: InkWell(
                      child: Text(
                        link['title'],
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                      onTap: () {
                        // 复制到系统剪切板
                        var data = ClipboardData(text: url);
                        Clipboard.setData(data);
                        Fluttertoast.showToast(
                          msg:
                              "【${link['title']}】【${link['url']}】已经复制到剪切板$codeDes",
                          toastLength: Toast.LENGTH_LONG,
                          gravity: ToastGravity.BOTTOM,
                          timeInSecForIos: 1,
                          backgroundColor: Colors.black54,
                          textColor: Colors.white,
                          fontSize: 16.0,
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  // 在线播放按钮
  liveGroup(List links, int flg) {
    var filterLinks =
        links.where((link) => link['url'].toString().endsWith(flg.toString()));
    return Container(
      width: ScreenUtil.screenWidth,
      child: Column(
        children: <Widget>[
          filterLinks.length > 0 ? Divider() : Container(),
          filterLinks.length > 0 ? Text('播放地址:') : Container(),
          Wrap(
            spacing: ScreenUtil().setWidth(10),
            children: filterLinks.map((link) {
              return RaisedButton(
                child: Text(link['title']),
                onPressed: () {
                  openBrower(link['url']);
                },
              );
            }).toList(),
          )
        ],
      ),
    );
  }

  // 打开浏览器
  openBrower(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      Fluttertoast.showToast(
        msg: "无法打开浏览器",
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIos: 1,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0,
      );
    }
  }

  // 匹配标题
  matchTitle(String movieHtml) {
    var regex = RegExp(r'<h1>.*?</h1>');
    var match = regex.firstMatch(movieHtml);
    var matchStr = match == null ? '' : match.group(0);
    return matchStr.replaceAll(RegExp('<.*?>'), '');
  }

  // 匹配封面
  matchImg(String movieHtml) {
    var reg = RegExp(r'http.*?(jpg|jpeg)');
    var match = reg.firstMatch(movieHtml);
    return match == null
        ? 'https://via.placeholder.com/500x500.png?text=no+found'
        : match.group(0);
  }

  // 匹配缩略图
  matchIntroduceImg(String movieHtml) {
    var reg = RegExp(r'https://lookimg.*?(jpg|jpeg)');
    var match = reg.firstMatch(movieHtml);
    return match == null ? null : match.group(0);
  }

  // 匹配简介
  matchIntroduce(String movieHtml) {
    var reg = RegExp(r'<div id="post(.|\n)*?<hr />');
    var matches = reg.allMatches(movieHtml);
    if (matches.length > 0) {
      var match = matches.last;
      var matchStr = match == null ? '' : match.group(0);
      matchStr = matchStr
          .replaceAll(RegExp(r'http.*?(jpg|jpeg)'), '')
          .replaceAll(RegExp(r'<hr.*'), '')
          .replaceAll('<img.*?>', '')
          .replaceAll('&amp;middot;', '');
      return matchStr;
    }

    reg = RegExp(r'<p>.*</p>');
    matches = reg.allMatches(movieHtml);
    if (matches.length > 0) {
      var match = matches.last;
      var matchStr = match == null ? '' : match.group(0);
      matchStr = matchStr
          .replaceAll(RegExp(r'http.*?(jpg|jpeg)'), '')
          .replaceAll(RegExp(r'<hr.*'), '')
          .replaceAll('<img.*?>', '')
          .replaceAll('&amp;middot;', '');
      return matchStr;
    }

    return '';
  }

  // 匹配下载链接
  matchDownloadLink(String movieHtml) {
    var reg = RegExp(r'<table(.|\n)*?</table>');
    var match = reg.firstMatch(movieHtml);
    if (match != null) {
      var tableStr = match.group(0);

      // 提取码
      var codeMatches = RegExp(r'提取码：.{4}')
          .allMatches(tableStr)
          .map((m) => m.group(0).replaceAll('提取码：', ''));

      // 链接地址
      var linkReg = RegExp(r'<a.*?/a>');
      var matches = linkReg.allMatches(tableStr);
      return matches.map((m) {
        var linkTitle = m.group(0).replaceAll(RegExp('<.*?>'), '');
        var linkUrl = m
            .group(0)
            .replaceAll(RegExp('target="_blank" '), '')
            .replaceAll(RegExp('<a href="'), '')
            .replaceAll(RegExp('".*'), '');
        return {
          'title': linkTitle,
          'url': linkUrl,
          'code': codeMatches.join(','),
        };
      }).toList();
    }
    return List();
  }

  // 匹配在线播放链接
  matchLiveUrl(String movieHtml) {
    var reg = RegExp(r'<a.*?lBtn.*?a>');
    var matches = reg.allMatches(movieHtml);
    return matches.map((m) {
      var aTagStr = m.group(0);
      var linkTitle = aTagStr.replaceAll(RegExp('<.*?>'), '');
      var linkUrl = aTagStr
          .replaceAll(RegExp('.*"https'), 'https')
          .replaceAll(RegExp('".*'), '');
      return {
        'title': linkTitle,
        'url': linkUrl,
      };
    }).toList();
  }
}
