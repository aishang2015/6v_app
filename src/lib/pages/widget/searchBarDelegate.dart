import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:movie_6v/pages/widget/movieCover.dart';
import 'package:movie_6v/utils/http.dart';
import 'package:movie_6v/utils/regex.dart';

class SearchBarDelegate extends SearchDelegate<String> {
  // 右侧内容
  @override
  List<Widget> buildActions(BuildContext context) {
    // TODO: implement buildActions
    return [
      IconButton(
        icon: Icon(Icons.clear),
        onPressed: () {
          query = '';
          showSuggestions(context);
        },
      )
    ];
  }

  // 左侧内容
  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: AnimatedIcon(
        icon: AnimatedIcons.menu_arrow,
        progress: transitionAnimation,
      ),
      onPressed: () {
        close(context, null);
      },
    );
  }

  // 搜索结果窗口
  @override
  Widget buildResults(BuildContext context) {
    return Center(
      child: movieList(),
    );
  }

  // 搜索建议窗口
  @override
  Widget buildSuggestions(BuildContext context) {
    return Container();
  }

  // 电影列表
  movieList() {
    var initPage = 1;
    var initFlg = false;
    var movieHtmlList = List<String>();
    var scrollController = ScrollController();
    return StatefulBuilder(
      builder: (context, modelSetState) {
        if (!initFlg) {
          initFlg = true;
          searchData(initPage, query, movieHtmlList, modelSetState);
        }

        scrollController.addListener(() {
          if (scrollController.position.pixels ==
              scrollController.position.maxScrollExtent) {
            searchData(++initPage, query, movieHtmlList, modelSetState);
          }
        });
        return Container(
          alignment: Alignment.topCenter,
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
            controller: scrollController,
          ),
        );
      },
    );
  }

  // 搜索数据
  searchData(int page, String keyword, List<String> movieHtmlList,
      StateSetter setState) async {
    var url = 'https://www.66s.cc/e/search/index.php';
    var data = {
      'show': 'title',
      'tempid': 1,
      'tbname': 'article',
      'mid': 1,
      'dopost': 'search',
      'keyboard': keyword
    };
    try {
      await HttpUtil.form(url, data);
    } on DioError catch (e) {
      if (e?.response?.statusCode == 302) {
        var realUri = RegexUtil.matchRedirectUri(e.response.data);
        if (page == 1) {
          realUri = 'https://www.66s.cc/e/search/$realUri';
        } else {
          realUri = 'https://www.66s.cc/e/search/$realUri'
              .replaceAll('result/?', 'result/index.php?page=${page - 1}&');
        }
        print(realUri);
        var realResponse = await HttpUtil.get(realUri);
        var list = RegexUtil.matchMovie(realResponse.data);
        setState(() => movieHtmlList.addAll(list));
      }
    }
  }
}
