library sprite_importer;

import "dart:convert";

import 'package:game_loop/game_loop_html.dart';

import "drawable.dart";
import "async_importer.dart";
import "base_geometry.dart";
import 'drawable_factory.dart';
import "animation.dart";
import "behaviour.dart";
import "game_state.dart";
import 'game_area.dart';
import 'geometry_data.dart';

import "enemy_behaviour.dart";
import 'pc_behaviour.dart';
import "camera.dart";

class SpriteData
{
  BaseGeometry geom_;
  AnimationData anim_;
  BehaviourDefinition behaviour_;

  void AddToGameState(SpriteLoader loader, TerrainBehaviour terrain, GameArea area, GameState state)
  {
    BaseDrawable drawable;
    if (anim_ != null)
    {
      drawable = loader.drawable_factory_.createAnimatedDrawable(geom_, anim_);
    }
    else
    {
      drawable = loader.drawable_factory_.createBaseDrawable(geom_);
    }
    area.addElement(drawable , behaviour_.getBehaviour(terrain, area, loader, state));
  }
}

abstract class BehaviourDefinition
{
  Behaviour getBehaviour(TerrainBehaviour terrain, GameArea area, SpriteLoader loader, GameState state);
}

class EnemyBehaviourDefinition implements BehaviourDefinition
{
  String path_name_;
  EnemyBehaviourDefinition(this.path_name_);

  Behaviour getBehaviour(TerrainBehaviour terrain, GameArea area, SpriteLoader loader, GameState state)
  {
    return new EnemyBehaviour(terrain, area.paths_[path_name_]);
  }
}

class PCBehaviourDefinition implements BehaviourDefinition
{
  double x_, y_;

  PCBehaviourDefinition(this.x_, this.y_);

  Behaviour getBehaviour(TerrainBehaviour terrain, GameArea area, SpriteLoader loader, GameState state)
  {
    return new PCBehaviour(x_, y_, terrain, loader.gameLoop_.keyboard, loader.cur_cam_, state);
  }
}

class SpriteLoader
{
  DrawableFactory drawable_factory_;
  GameLoopHtml gameLoop_;
  Camera cur_cam_;

  SpriteLoader(this.drawable_factory_, this.gameLoop_, this.cur_cam_);

  void AddToGameState(List<SpriteData> sprites_data, TerrainBehaviour terrain, GameArea area, GameState state)
  {
    for (SpriteData sprite in sprites_data)
    {
      sprite.AddToGameState(this, terrain, area, state);
    }
  }
}

class SpriteImporter extends AsyncImporter<List<SpriteData>>
{
  void processDrawable(Map drawable_spec, SpriteData res)
  {
    res.geom_ = new TexturedGeometry(quad_vertices, quad_indices, quad_coords, drawable_spec["path"]);
    if (drawable_spec.containsKey("sequences"))
    {
      res.anim_ = new AnimationData();
      res.anim_.num_images_side_ = drawable_spec["num_images_side"];
      res.anim_.sequences_ = new Map<String, AnimationSequence>();
      for (Map sequence in drawable_spec["sequences"])
      {
        String name = sequence["name"];
        double speed = sequence["time"];
        List<int> seq = sequence["sequence"];
        res.anim_.sequences_[name] = new AnimationSequence(seq, speed);
      }
    }
  }

  void processBehaviour(Map behaviour_spec, SpriteData res)
  {
    switch(behaviour_spec["type"])
    {
      case "EnemyBehaviour":
        res.behaviour_ = new EnemyBehaviourDefinition(behaviour_spec["path"]);
        break;
      case "PCBehaviour":
        res.behaviour_ = new PCBehaviourDefinition(behaviour_spec["posx"], behaviour_spec["posy"]);
        break;
    }
  }

  void _extend(Map extended, Map base)
  {
    base.forEach((key, value)
    {
      if (extended.containsKey(key))
      {
        if (base[key] is Map)
        {
          _extend(extended[key], base[key]);
        }
      }
      else
      {
        extended[key] = value;
      }
    });
  }

  List<SpriteData> processFile(String data)
  {
    List<SpriteData> ret = new List<SpriteData>();
    Map jsonData = JSON.decode(data);
    Map<String, Map> prototypes = new Map<String, Map>();

    jsonData.forEach((key, value)
    {
      prototypes[key] = value;
      Map spec = value;
      if (spec.containsKey("parent") && prototypes.containsKey(spec["parent"]))
      {
        _extend(spec, prototypes[spec["parent"]]);
      }
      SpriteData current = new SpriteData();

      processDrawable(value["drawable"], current);
      processBehaviour(value["behaviour"], current);
      ret.add(current);
    });

    return ret;
  }
}