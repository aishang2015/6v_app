import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:movie_6v/utils/regex.dart';

class MovieCover extends StatelessWidget {
  final String html;

  MovieCover(this.html, {Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var url = RegexUtil.matchImg(html);
    var title = RegexUtil.matchTitle(html);
    var movieType = RegexUtil.matchMovieType(html);
    var movieUrl = RegexUtil.matchMovieUrl(html);
    return GestureDetector(
      onTap: () {
        if (movieUrl != '') {
          Navigator.pushNamed(context, 'detail', arguments: movieUrl);
        }
      },
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: <Widget>[
          ConstrainedBox(
            constraints: BoxConstraints(minHeight: 200),
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: 20),
              child: CachedNetworkImage(
                imageUrl: url,
                fit: BoxFit.fill,
                placeholder: (context, url) => Center(
                  child: SizedBox(
                    width: 30,
                    height: 30,
                    child: CircularProgressIndicator(),
                  ),
                ),
                errorWidget: (context, url, error) => Icon(Icons.error),
              ),
            ),
          ),

          // 蒙板
          Positioned(
            child: Container(
              height: ScreenUtil().setHeight(70),
              decoration: BoxDecoration(color: Colors.black54),
            ),
          ),

          // 视频名称
          Positioned(
            bottom: ScreenUtil().setHeight(10),
            child: Text(
              title,
              style: TextStyle(
                color: Colors.white,
                fontSize: ScreenUtil().setSp(40),
              ),
            ),
          ),

          // 视频类型
          Positioned(
            top: 10,
            right: 10,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.black54,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                movieType,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: ScreenUtil().setSp(40),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
