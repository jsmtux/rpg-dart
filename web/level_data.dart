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
import 'path.dart';

class LevelData
{
  List<SquareTerrain> terrain_list_;
  List<String> models_ = new List<String>();
  List<Vector3> model_info_ = new List<Vector3>();
  Map<String, Path> paths_ = new Map<String, Path>();
  List<List<int>> heights_;

  Map<String,BaseGeometry> models_geometry_ = new Map<String, BaseGeometry>();

  LevelData(this.terrain_list_, this.models_, this.model_info_, this.heights_, this.paths_);

  Future<TerrainBehaviour> AddToGameState(GameState state, DrawableFactory drawable_factory)
  {
    Completer completer = new Completer();
    TerrainBehaviour behaviour_t = new TerrainBehaviour(heights_);

    double height = 0.0;
    for (SquareTerrain sq in terrain_list_)
    {
      BaseGeometry terrain_geom = sq.calculateBaseGeometry(height);
      height += 0.005;

      Drawable terrain_drawable = drawable_factory.createTexturedDrawable(terrain_geom);
      EngineElement e1 = state.addElement(terrain_drawable, behaviour_t);
      Quaternion rot = new Quaternion.identity();
      //rot.setAxisAngle(new Vector3(1.0, 0.0, 0.0 ), -60 * (math.PI / 180));
      e1.drawable_.Rotate(rot);
    }

    if (paths_ != null)
    {
      state.paths_.addAll(paths_);
    }

    if (models_ != null)
    {
      ModelImporter importer = new ModelImporter();
      for (String path in models_)
      {
        importer.RequestFile(path).then((List<BaseGeometry> model) => checkFinished(state, model, path, completer, drawable_factory, behaviour_t));
      }
    }
    else
    {
      completer.complete(behaviour_t);
    }

    return completer.future;
  }

  void checkFinished(GameState state, List<BaseGeometry> model, String path, Completer completer, DrawableFactory drawable_factory, TerrainBehaviour behaviour_t)
  {
    models_geometry_[path] = model[0];
    if (models_.length == models_geometry_.length)
    {
      processFinished(state, completer, drawable_factory, behaviour_t);
    }
  }

  void processFinished(GameState state, Completer completer, DrawableFactory drawable_factory, TerrainBehaviour behaviour_t)
  {
    for (Vector3 info in model_info_)
    {
      double x = info.x;
      double y = info.y;
      int z = info.z.floor();
      EngineElement el = state.addElement(
          drawable_factory.createTexturedDrawable(models_geometry_[models_[z]]), new Tile3dBehaviour(x, y, behaviour_t));
      el.drawable_.setScale(1/3);
    }
    completer.complete(behaviour_t);
  }
}