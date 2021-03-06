library sprite_importer;

import "dart:convert";

import 'package:vector_math/vector_math.dart';

import "drawable.dart";
import "async_importer.dart";
import "base_geometry.dart";
import 'drawable_factory.dart';
import "animation.dart";
import "game_state.dart";
import 'game_area.dart';
import 'geometry_data.dart';
import "camera.dart";
import "dialogue_box.dart";
import 'input.dart';

import 'behaviour/behaviour.dart';
import 'behaviour/pc_behaviour.dart';
import 'behaviour/terrain_behaviour.dart';
import 'behaviour/sign_behaviour.dart';
import 'behaviour/enemy_behaviour.dart';
import 'behaviour/sheep_behaviour.dart';
import 'behaviour/button_behaviour.dart';
import 'behaviour/door_behaviour.dart';

class SpriteData
{
  List<BaseGeometry> geom_ = new List<BaseGeometry>();
  AnimationData anim_;
  BehaviourDefinition behaviour_;

  void AddToGameState(SpriteLoader loader, TerrainBehaviour terrain, GameArea area, GameState state)
  {
    BaseDrawable drawable;
    if (geom_.length > 1)
    {
      drawable = loader.drawable_factory_.createAnimatedDrawable(geom_);
    }
    else if (anim_ != null)
    {
      drawable = loader.drawable_factory_.createSpriteDrawable(geom_.first, anim_);
    }
    else
    {
      drawable = loader.drawable_factory_.createTexturedDrawable(geom_.first);
    }
    if (behaviour_ == null)
    {
      print("Behaviour is null!");
    }
    area.addElement(drawable , behaviour_.getBehaviour(area, loader, state));
  }
}

abstract class BehaviourDefinition
{
  Behaviour getBehaviour(GameArea area, SpriteLoader loader, GameState state);
}

class EnemyBehaviourDefinition implements BehaviourDefinition
{
  String path_name_;
  EnemyBehaviourDefinition(this.path_name_);

  Behaviour getBehaviour(GameArea area, SpriteLoader loader, GameState state)
  {
    return new EnemyBehaviour(area, area.paths_[path_name_]);
  }
}

class PCBehaviourDefinition implements BehaviourDefinition
{
  Vector2 position_;

  PCBehaviourDefinition(this.position_);

  Behaviour getBehaviour(GameArea area, SpriteLoader loader, GameState state)
  {
    return new PCBehaviour(position_, area, loader.input_, loader.cur_cam_, state);
  }
}

class SignBehaviourDefinition implements BehaviourDefinition
{
  String text_;
  Vector2 position_;

  SignBehaviourDefinition(this.text_, this.position_);

  Behaviour getBehaviour(GameArea area, SpriteLoader loader, GameState state)
  {
    return new SignBehaviour(position_, area, text_, loader.text_output_);
  }
}

class SheepBehaviourDefinition implements BehaviourDefinition
{
  Vector2 position_;

  SheepBehaviourDefinition(this.position_);

  Behaviour getBehaviour(GameArea area, SpriteLoader loader, GameState state)
  {
    return new SheepBehaviour(position_, area);
  }
}

class GoldSheepBehaviourDefinition implements BehaviourDefinition
{
  Vector2 position_;

  GoldSheepBehaviourDefinition(this.position_);

  Behaviour getBehaviour(GameArea area, SpriteLoader loader, GameState state)
  {
    return new GoldSheepBehaviour(position_, area);
  }
}

class ButtonBehaviourDefinition implements BehaviourDefinition
{
  Vector2 position_;
  String object_;

  ButtonBehaviourDefinition(this.position_, this.object_);

  Behaviour getBehaviour(GameArea area, SpriteLoader loader, GameState state)
  {
    return new ButtonBehaviour(position_, area, object_);
  }
}

class DoorBehaviourDefinition implements BehaviourDefinition
{
  Vector2 position_;
  String name_;

  DoorBehaviourDefinition(this.position_, this.name_);

  Behaviour getBehaviour(GameArea area, SpriteLoader loader, GameState state)
  {
    return new DoorBehaviour(position_, area, name_);
  }
}

class SpriteLoader
{
  DrawableFactory drawable_factory_;
  Input input_;
  Camera cur_cam_;
  TextOutput text_output_;
  Map<String,BaseGeometry> models_geometry_ = new Map<String, BaseGeometry>();

  SpriteLoader(this.drawable_factory_, this.input_, this.cur_cam_, this.text_output_);

  void AddToGameState(List<SpriteData> sprites_data, TerrainBehaviour terrain, GameArea area, GameState state)
  {
    for (SpriteData sprite in sprites_data)
    {
      sprite.AddToGameState(this, terrain, area, state);
    }
  }

  void addModels(Map<String,BaseGeometry> models)
  {
    models_geometry_.addAll(models);
  }

  BaseGeometry getModelGeometry(String name)
  {
    return models_geometry_[name];
  }
}

class SpriteImporter extends AsyncImporter<List<SpriteData>>
{
  SpriteLoader loader_;
  Vector3 offset_;

  SpriteImporter(this.loader_, this.offset_);

  void processDrawable(Map drawable_spec, SpriteData res)
  {
    if(drawable_spec["type"]=="quad")
    {
      res.geom_.add(new TexturedGeometry(quad_vertices, null, quad_indices, quad_coords, drawable_spec["path"]));
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
    else if (drawable_spec["type"] == "model")
    {
      res.geom_.add(loader_.getModelGeometry(drawable_spec["path"]));
    }
    else if (drawable_spec["type"] == "animation")
    {
      int i = 0;
      while(drawable_spec.containsKey("path$i"))
      {
        res.geom_.add(loader_.getModelGeometry(drawable_spec["path$i"]));
        i++;
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
        res.behaviour_ = new PCBehaviourDefinition(offset_.xy + new Vector2(behaviour_spec["posx"], behaviour_spec["posy"]));
        break;
      case "SignBehaviour":
        res.behaviour_ = new SignBehaviourDefinition(behaviour_spec["text"], offset_.xy + new Vector2(behaviour_spec["posx"], behaviour_spec["posy"]));
        break;
      case "SheepBehaviour":
        res.behaviour_ = new SheepBehaviourDefinition(offset_.xy + new Vector2(behaviour_spec["posx"], behaviour_spec["posy"]));
        break;
      case "GoldSheepBehaviour":
      case "CoolSheepBehaviour":
        res.behaviour_ = new GoldSheepBehaviourDefinition(offset_.xy + new Vector2(behaviour_spec["posx"], behaviour_spec["posy"]));
        break;
      case "ButtonBehaviour":
        String object;
        if (behaviour_spec["properties"] != null)
        {
          object = behaviour_spec["properties"]["object"];
        }
        res.behaviour_ = new ButtonBehaviourDefinition(offset_.xy + new Vector2(behaviour_spec["posx"], behaviour_spec["posy"]), object);
        break;
      case "DoorBehaviour":
        res.behaviour_ = new DoorBehaviourDefinition(offset_.xy + new Vector2(behaviour_spec["posx"], behaviour_spec["posy"]), behaviour_spec["name"]);
        break;
      default:
        print("Behaviour type " + behaviour_spec["type"] + " not found");
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