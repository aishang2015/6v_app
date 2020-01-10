import 'dart:convert';

import 'package:flutter/services.dart';

class ConfigUtil {

  // 缓存配置
  static CacheOption cacheOption;

  // 初始化对象
  static init() async {

    if(cacheOption == null){
      var cacheOptionStr = await rootBundle.loadString('configs/cache.json');
      var cacheOptionObject = json.decode(cacheOptionStr);
      cacheOption = CacheOption.fromJson(cacheOptionObject);
    }

  }
}

class CacheOption {
  bool isEnable;
  int expire;
  int maxCount;

  CacheOption(this.isEnable, this.expire, this.maxCount);

  CacheOption.fromJson(Map<String, dynamic> json) {
    isEnable = json['isEnable'];
    expire = json['expire'];
    maxCount = json['maxCount'];
  }

  Map<String, dynamic> toJson() {
    return {
      'isEnable': isEnable,
      'expire': expire,
      'maxCount': maxCount,
    };
  }
}
