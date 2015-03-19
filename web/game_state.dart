library game_state;

import 'dart:html';
import 'dart:async';

import 'package:game_loop/game_loop_html.dart';

import 'drawable.dart';
import 'renderer.dart';
import 'behaviour.dart';
import 'path.dart';
import 'level_importer.dart';
import 'level_data.dart';
import 'drawable_factory.dart';
import 'sprite_importer.dart';
import 'camera.dart';

class GameState extends SimpleHtmlState
{
  Renderer renderer_;
  List<Drawable> drawables_ = new List<Drawable>();
  List<Behaviour> behaviours_ = new List<Behaviour>();
  Map<String, Path> paths_ = new Map<String, Path>();

  Future<TerrainBehaviour> loadTerrain(String level_path, DrawableFactory drawable_factory)
  {
    LevelImporter level_importer = new LevelImporter();
    return level_importer.RequestFile(level_path).then((LevelData data) => (data.AddToGameState(this, drawable_factory)));
  }

  void initBehaviour(String behaviour_path, TerrainBehaviour terrain, GameState state, DrawableFactory drawable_factory, GameLoopHtml gameLoop, Camera cur_cam)
  {
    SpriteImporter sprite_importer = new SpriteImporter();
    sprite_importer.RequestFile(behaviour_path).then(
      (loader)
      {
        loader.configure(terrain, state, drawable_factory, gameLoop, cur_cam);
        loader.AddToGameState();
      }
    );

    gameLoop.state = this;

  }

  void addElement(Drawable drawable, Behaviour behaviour)
  {
    if (behaviour != null)
    {
      behaviour.init(drawable);
    }

    drawables_.add(drawable);
    behaviours_.add(behaviour);
    int num_elements = drawables_.length;
  }

  void onRender(GameLoop gameLoop) {
    renderer_.render(drawables_);
  }

  void onUpdate(GameLoop gameLoop)
  {
    for (Behaviour behaviour in behaviours_)
    {
      behaviour.update(this);
    }
  }

  void onKeyDown(KeyboardEvent event) {
  }

  GameState(Renderer renderer)
  {
    renderer_ = renderer;
  }
}