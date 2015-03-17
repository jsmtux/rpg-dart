import 'dart:html';
import 'dart:async';

import 'package:game_loop/game_loop_html.dart';

import 'renderer.dart';
import 'game_state.dart';
import 'drawable_factory.dart';
import 'level_importer.dart';
import 'level_data.dart';
import 'behaviour.dart';
import 'camera.dart';
import 'sprite_importer.dart';

void initGame (TerrainBehaviour terrain, GameState state, DrawableFactory drawable_factory, GameLoopHtml gameLoop, Camera cur_cam)
{
  SpriteImporter sprite_importer = new SpriteImporter();
  sprite_importer.RequestFile("images/map_units_test.json").then(
      (loader)
      {
        loader.configure(terrain, state, drawable_factory, gameLoop, cur_cam);
        loader.AddToGameState();
      }
  );

  gameLoop.start();
}

main() {
  CanvasElement canvas = querySelector(".game-element");
  GameLoopHtml gameLoop = new GameLoopHtml(canvas);

  Renderer renderer = new Renderer(canvas);
  DrawableFactory drawable_factory = new DrawableFactory(renderer);
  GameState draw_state = new GameState(renderer);

  LevelImporter level_importer = new LevelImporter();
  Future<TerrainBehaviour> import_res =
      level_importer.RequestFile("images/map_test.json").then((LevelData data) => (data.AddToGameState(draw_state, drawable_factory)));

  Camera cur_cam = new Camera(renderer.m_worldview_);

  gameLoop.state = draw_state;

  import_res.then((res) => initGame(res, draw_state, drawable_factory, gameLoop, cur_cam));
}
