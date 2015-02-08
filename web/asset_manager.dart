library asset_manager;

import 'dart:web_gl' as webgl;

class AssetManager<T>
{
  Map<String, T> asset_list_ = new Map();
  webgl.RenderingContext gl_;

  AssetManager(this.create_asset_);

  T getAsset(String name)
  {
    asset_list_.putIfAbsent(name, () => create_asset_(name));
    return asset_list_[name];
  }

  Function create_asset_;
}