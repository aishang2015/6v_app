import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:movie_6v/pages/widget/movieCover.dart';
import 'package:movie_6v/pages/widget/searchBarDelegate.dart';
import 'package:movie_6v/utils/http.dart';
import 'package:movie_6v/utils/regex.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  var data = [
    {'title': '推荐', 'url': ''},
    {
      'title': '喜剧片',
      'url': 'xijupian',
    },
    {
      'title': '动作片',
      'url': 'dongzuopian',
    },
    {
      'title': '爱情片',
      'url': 'aiqingpian',
    },
    {
      'title': '科幻片',
      'url': 'kehuanpian',
    },
    {
      'title': '恐怖片',
      'url': 'kongbupian',
    },
    {
      'title': '剧情片',
      'url': 'juqingpian',
    },
    {
      'title': '战争片',
      'url': 'zhanzhengpian',
    },
    {
      'title': '纪录片',
      'url': 'jilupian',
    },
    {
      'title': '动画片',
      'url': 'donghuapian',
    },
    {
      'title': '电视剧',
      'url': 'dianshiju',
    },
    {
      'title': '综艺',
      'url': 'ZongYi',
    },
  ];

  var currentValue = '推荐';

  var baseUrl = 'https://www.66s.cc/';

  var _scrollController = ScrollController();

  int page = 1;

  var movieHtmlList = List<String>();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    getMovieList(1, '');

    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        var selectedData = data.firstWhere((d) => d['title'] == currentValue);
        getMovieList(++page, selectedData['url']);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    ScreenUtil.instance = ScreenUtil.getInstance()..init(context);
    return Scaffold(
      appBar: AppBar(
        title: appBar(),
      ),
      body: movieList(),
    );
  }

  // 标题栏
  appBar() {
    return AppBar(
      centerTitle: true,
      actions: <Widget>[
        IconButton(
          icon: Icon(Icons.search),
          onPressed: () {
            showSearch(context: context, delegate: SearchBarDelegate());
          },
        )
      ],
      title: Theme(
        data: Theme.of(context)
            .copyWith(canvasColor: Theme.of(context).primaryColor),
        child: DropdownButton(
          style: TextStyle(
            color: Colors.white,
            fontSize: ScreenUtil().setSp(50),
          ),
          underline: Container(),
          onChanged: (value) {
            setState(() {
              if (currentValue != value) {
                currentValue = value;
                var selectedData = data.firstWhere((d) => d['title'] == value);
                getMovieList(1, selectedData['url']);
                page = 1;
              }
            });
          },
          value: currentValue,
          iconEnabledColor: Colors.white,
          items: data.map((d) {
            return DropdownMenuItem(
              value: d['title'],
              child: Container(
                color: Theme.of(context).primaryColor,
                child: Text(d['title']),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  // 电影列表
  movieList() {
    if (movieHtmlList.length == 0) {
      return Center(
        child: CircularProgressIndicator(),
      );
    }
    return RefreshIndicator(
      onRefresh: () async {
        var selectedData = data.firstWhere((d) => d['title'] == currentValue);
        getMovieList(1, selectedData['url']);
        page = 1;
        return;
      },
      child: StaggeredGridView.countBuilder(
        shrinkWrap: true,
        primary: false,
        crossAxisCount: 2,
        itemCount: movieHtmlList.length,
        mainAxisSpacing: 1,
        crossAxisSpacing: 1,
        itemBuilder: (context, index) {
          var movieHtml = movieHtmlList[index];
          return MovieCover(movieHtml);
        },
        staggeredTileBuilder: (int index) => StaggeredTile.fit(1),
        controller: _scrollController,
      ),
    );
  }

  // 取得电影列表数据
  getMovieList(int page, String url) async {
    var listUrl = '$baseUrl$url';
    if (page == 1) {
      movieHtmlList.clear();
    } else {
      listUrl = '$listUrl/index_$page.html';
    }

    try {
      var response = await HttpUtil.get(listUrl);
      var list = RegexUtil.matchMovie(response.data);
      if (list.length > 0) {
        setState(() {
          movieHtmlList.addAll(list);
        });
      } else {
        var code = RegexUtil.matchValidateCode(response.data);
        if (code != '') {
          getMovieList(1, '$url/$code');
        } else {
          Fluttertoast.showToast(
            msg: "无法取得数据,请稍后重试",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIos: 1,
            backgroundColor: Colors.red.shade400,
            textColor: Colors.white,
            fontSize: 16.0,
          );
        }
      }
    } on DioError catch (e) {
      Fluttertoast.showToast(
        msg: "没有更多资源了",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIos: 1,
        backgroundColor: Colors.yellow,
        textColor: Colors.white,
        fontSize: 16.0,
      );
    }
  }
}
