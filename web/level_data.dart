library level_data;

import 'dart:async';

import 'package:vector_math/vector_math.dart';

import "square_terrain.dart";
import 'game_area.dart';
import 'drawable_factory.dart';
import 'base_geometry.dart';
import 'drawable.dart';
import 'model_importer.dart';
import 'behaviour.dart';
import 'path.dart';
import 'portal.dart';
import 'game_state.dart';

class LevelData
{
  List<SquareTerrain> terrain_list_;
  List<String> models_ = new List<String>();
  List<Vector3> model_info_ = new List<Vector3>();
  Map<String, Path> paths_ = new Map<String, Path>();
  List<List<int>> heights_;
  Vector3 offset_;
  Map<String, List<Vector2>> portals_;

  Map<String,BaseGeometry> models_geometry_ = new Map<String, BaseGeometry>();

  LevelData(this.terrain_list_, this.models_, this.model_info_, this.heights_, this.paths_, this.portals_, this.offset_);

  Future<TerrainBehaviour> AddToGameState(GameArea area, GameState state, DrawableFactory drawable_factory)
  {
    Completer completer = new Completer();
    TerrainBehaviour behaviour_t = new TerrainBehaviour(heights_, offset_);
    area.terrain_ = behaviour_t;

    double height = 0.0;
    for (SquareTerrain sq in terrain_list_)
    {
      BaseGeometry terrain_geom = sq.calculateBaseGeometry(height);
      height += 0.005;

      Drawable terrain_drawable = drawable_factory.createTexturedDrawable(terrain_geom);
      area.addElement(terrain_drawable, behaviour_t);
      Quaternion rot = new Quaternion.identity();
      //rot.setAxisAngle(new Vector3(1.0, 0.0, 0.0 ), -60 * (math.PI / 180));
      terrain_drawable.Rotate(rot);
      terrain_drawable.setPosition(offset_);
    }

    if (paths_ != null)
    {
      area.paths_.addAll(paths_);
    }

    portals_.forEach((String name, List<Vector2> positions){
      for (Vector2 pos in positions)
      {
        pos.x += offset_.x;
        pos.y += offset_.y;
      }
      behaviour_t.addPortal(new Portal(name, state), positions);
    });

    if (models_ != null)
    {
      ModelImporter importer = new ModelImporter();
      for (String path in models_)
      {
        importer.RequestFile(path).then((List<BaseGeometry> model) => checkFinished(area, model, path, completer, drawable_factory, behaviour_t));
      }
    }
    else
    {
      completer.complete(behaviour_t);
    }

    return completer.future;
  }

  void checkFinished(GameArea area, List<BaseGeometry> model, String path, Completer completer, DrawableFactory drawable_factory, TerrainBehaviour behaviour_t)
  {
    models_geometry_[path] = model[0];
    if (models_.length == models_geometry_.length)
    {
      processFinished(area, completer, drawable_factory, behaviour_t);
    }
  }

  void processFinished(GameArea area, Completer completer, DrawableFactory drawable_factory, TerrainBehaviour behaviour_t)
  {
    for (Vector3 info in model_info_)
    {
      double x = info.x + offset_.x;
      double y = info.y + offset_.y;
      int z = info.z.floor();
      Drawable toAdd = drawable_factory.createTexturedDrawable(models_geometry_[models_[z]]);
      area.addElement(toAdd , new Tile3dBehaviour(x, y, behaviour_t));
      toAdd.setScale(1/3);
    }
    completer.complete(behaviour_t);
  }
}