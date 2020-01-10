class RegexUtil {
  // 匹配电影列表
  static matchMovie(String content) {
    var reg = RegExp(r'<li class="post[\s\S]*?<\/li>');
    var matches = reg.allMatches(content);
    return matches.map((match) => match.group(0)).toList();
  }

  // 匹配随机码
  static matchValidateCode(String content) {
    var reg = RegExp(r'\?.*?"');
    var match = reg.firstMatch(content);
    return match == null ? '' : match.group(0);
  }

  // 匹配封面
  static matchImg(String movieHtml) {
    var reg = RegExp(r'http.*?(jpg|jpeg)');
    var match = reg.firstMatch(movieHtml);
    return match == null
        ? 'https://via.placeholder.com/500x500.png?text=no+found'
        : match.group(0);
  }

  // 匹配标题
  static matchTitle(String movieHtml) {
    var reg = RegExp(r'<h2>.*?</h2>');
    var match = reg.firstMatch(movieHtml);
    var matchStr = match == null ? '' : match.group(0);
    return matchStr.replaceAll(RegExp(r'<a.*?">'), '')
        .replaceAll(RegExp(r'<.*?>'), '');
  }

  // 匹配类型
  static matchMovieType(String movieHtml) {
    var reg = RegExp(r'<span class="info_category.*?</span>');
    var match = reg.firstMatch(movieHtml);
    var matchStr = match == null ? '' : match.group(0);
    return matchStr.replaceAll(RegExp(r'<.*?>'), '');
  }

  // 匹配电影详细地址
  static matchMovieUrl(String movieHtml) {
    var reg = RegExp(r'https://.*?(html)');
    var match = reg.firstMatch(movieHtml);
    return match == null ? '' : match.group(0);
  }

  // 匹配重定向地址
  static matchRedirectUri(String html) {
    var reg = RegExp(r'".*?"');
    var match = reg.firstMatch(html);
    var matchStr = match == null ? '' : match.group(0);
    return matchStr.replaceAll(RegExp(r'"'), '');
  }
}
