library level_data;

import 'dart:async';

import 'package:vector_math/vector_math.dart';

import "square_terrain.dart";
import 'game_state.dart';
import 'drawable_factory.dart';
import 'base_geometry.dart';
import 'drawable.dart';
import 'element.dart';
import 'model_importer.dart';
import 'behaviour.dart';

class LevelData
{
  List<SquareTerrain> terrain_list_;
  List<String> models_ = new List<String>();
  List<Vector3> model_info_ = new List<Vector3>();

  Map<String,BaseGeometry> models_geometry_ = new Map<String, BaseGeometry>();

  LevelData(this.terrain_list_, this.models_, this.model_info_);

  Future<bool> AddToGameState(GameState state, DrawableFactory drawable_factory)
  {
    Completer completer = new Completer();

    double height = 0.0;
    for (SquareTerrain sq in terrain_list_)
    {
      BaseGeometry terrain_geom = sq.calculateBaseGeometry(height);
      height += 0.005;

      Drawable terrain_drawable = drawable_factory.createTexturedDrawable(terrain_geom);
      EngineElement e1 = state.addElement(terrain_drawable, null);
      Quaternion rot = new Quaternion.identity();
      //rot.setAxisAngle(new Vector3(1.0, 0.0, 0.0 ), -60 * (math.PI / 180));
      e1.drawable_.Rotate(rot);
    }

    if (models_ != null)
    {
      ModelImporter importer = new ModelImporter();
      for (String path in models_)
      {
        importer.RequestFile(path).then((List<BaseGeometry> model) => checkFinished(state, model, path, completer, drawable_factory));
      }
    }
    else
    {
      completer.complete(true);
    }

    return completer.future;
  }

  void checkFinished(GameState state, List<BaseGeometry> model, String path, Completer completer, DrawableFactory drawable_factory)
  {
    models_geometry_[path] = model[0];
    if (models_.length == models_geometry_.length)
    {
      processFinished(state, completer, drawable_factory);
    }
  }

  void processFinished(GameState state, Completer completer, DrawableFactory drawable_factory)
  {
    for (Vector3 info in model_info_)
    {
      int x = info.x.floor();
      int y = info.y.floor();
      int z = info.z.floor();
      EngineElement el = state.addElement(
          drawable_factory.createTexturedDrawable(models_geometry_[models_[z]]), new Tile3dBehaviour(x, y));
      el.drawable_.setScale(1/3);
    }
    completer.complete(true);
  }
}