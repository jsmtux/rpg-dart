library game_area;

import 'dart:async';

import 'path.dart';
import 'level_importer.dart';
import 'level_data.dart';
import 'drawable.dart';
import 'sprite_importer.dart';
import 'game_state.dart';
import 'behaviour/behaviour.dart';
import 'behaviour/terrain_behaviour.dart';


class GameArea
{
  List<Drawable> drawables_ = new List<Drawable>();
  List<Behaviour> behaviours_ = new List<Behaviour>();
  Map<String, Path> paths_ = new Map<String, Path>();
  TerrainBehaviour terrain_;

  Future<bool> LoadGameArea(String level_path, String behaviour_path, SpriteLoader loader, GameState state)
  {
    Completer ret = new Completer();
    loadTerrain(level_path, state, loader)
        .then((res)
        {
          if(behaviour_path != null)
            initBehaviour(behaviour_path, res, loader, state);
          ret.complete(true);
        });
    return ret.future;
  }

  Future<TerrainBehaviour> loadTerrain(String level_path, GameState state, SpriteLoader loader)
  {
    LevelImporter level_importer = new LevelImporter();
    return level_importer.RequestFile(level_path).then((LevelData data) => (data.AddToGameState(this, state, loader)));
  }

  void initBehaviour(String behaviour_path, TerrainBehaviour terrain, SpriteLoader loader, GameState state)
  {
    SpriteImporter sprite_importer = new SpriteImporter(loader);
    sprite_importer.RequestFile(behaviour_path).then(
      (sprites)
      {
        loader.AddToGameState(sprites, terrain, this, state);
      }
    );
  }

  void addElement(Drawable drawable, Behaviour behaviour)
  {
    if (behaviour != null)
    {
      behaviour.init(drawable);
    }

    drawables_.add(drawable);
    behaviours_.add(behaviour);
  }
}