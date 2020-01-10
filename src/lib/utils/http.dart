import 'dart:collection';

import 'package:dio/dio.dart';
import 'package:movie_6v/utils/config.dart';

class HttpUtil {
  // 初始化dio对象
  static Dio dio = Dio();

  // 初始化拦截器
  static void initDioInterceptors() {
    dio.interceptors.add(CacheInterceptor());
  }

  static Future<Response> get(String uri, {bool useCache = true}) async {
    var response =
        await dio.get(uri, options: Options(extra: {'useCache': useCache}));
    return response;
  }

  static Future<Response> form(String uri, Map<String, dynamic> map) async {
    var formData = FormData.fromMap(map);
    var response = await dio.post(uri, data: formData);
    return response;
  }
}

class CacheInterceptor extends Interceptor {
  // 缓存对象列表
  var cacheMap = LinkedHashMap<String, CacheObject>();

  @override
  Future onRequest(RequestOptions options) async {
    // 缓存配置
    var config = ConfigUtil.cacheOption;

    // 使用缓存
    if (config.isEnable) {
      // 缓存的key
      var key = options.uri.toString();

      // 当前请求是否利用缓存
      var isUseCache = options.extra['useCache'] as bool;
      if (!isUseCache) {
        // 清空缓存
        cacheMap.remove(key);
        return options;
      }

      // 校验缓存是否过期
      if (options.method.toLowerCase() == 'get') {
        var cacheObj = cacheMap[key];
        if (cacheObj != null) {
          // 没有过期
          if (DateTime.now().millisecondsSinceEpoch - cacheObj.timeStamp <
              config.expire) {
            return cacheObj.response;
          } else {
            // 已经过期
            cacheMap.remove(key);
          }
        }
      }
    }

    return options;
  }

  // 更新缓存
  @override
  Future onResponse(Response response) async {
    // 缓存配置
    var config = ConfigUtil.cacheOption;

    // 是否使用缓存
    if (config.isEnable) {
      // 更新缓存
      var options = response.request;
      var key = options.uri.toString();
      if (options.method.toLowerCase() == 'get') {
        // 超出最大数量删除
        while (cacheMap.length >= config.maxCount) {
          cacheMap.remove(cacheMap.keys.first);
        }

        // 更新缓存
        cacheMap.update(key, (cache) => CacheObject(response),
            ifAbsent: () => CacheObject(response));
      }
    }

    return response;
  }
}

// 缓存对象
class CacheObject {
  // http响应
  Response response;

  // 时间戳
  int timeStamp;

  // 构造
  CacheObject(this.response)
      : timeStamp = DateTime.now().millisecondsSinceEpoch;
}
