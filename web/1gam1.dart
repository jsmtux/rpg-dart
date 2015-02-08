import 'dart:html';
import 'dart:async';

import 'package:game_loop/game_loop_html.dart';
import 'package:vector_math/vector_math.dart';

import 'renderer.dart';
import 'game_state.dart';
import 'drawable_factory.dart';
import 'level_importer.dart';
import 'level_data.dart';

main() {
  CanvasElement canvas = querySelector(".game-element");
  GameLoopHtml gameLoop = new GameLoopHtml(canvas);

  Renderer renderer = new Renderer(canvas);
  DrawableFactory drawable_factory = new DrawableFactory(renderer);
  GameState draw_state = new GameState(renderer);

  renderer.m_worldview_.translate(-5.0, -2.0, -45.0);
  renderer.m_worldview_.rotate(new Vector3(-1.0,0.0,0.0), radians(45.0));

  LevelImporter level_importer = new LevelImporter();
  Future<bool> import_res = level_importer.RequestFile("images/map_test.json").then((LevelData data) => (data.AddToGameState(draw_state, drawable_factory)));

  gameLoop.state = draw_state;

  import_res.then((res) => gameLoop.start());
}
