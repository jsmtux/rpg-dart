import 'dart:html';

import 'package:game_loop/game_loop_html.dart';

import 'renderer.dart';
import 'game_state.dart';
import 'drawable_factory.dart';
import 'camera.dart';
import 'sprite_importer.dart';
import 'dialogue_box.dart';
import 'input.dart';

main() {
  CanvasElement canvas = querySelector("#game-element");
  DivElement div = querySelector("#game-area");
  DivElement div_analog = querySelector('#analog_control_base');
  GameLoopHtml gameLoop = new GameLoopHtml(canvas);
  gameLoop.pointerLock.lockOnClick = false;
  Input input;

  input = new CombinedInput(canvas, div_analog, gameLoop.keyboard);

  DialogueBox dialogue = new DialogueBox(querySelector("#dialogue"));

  Camera cur_cam = new Camera();

  Renderer renderer = new Renderer(div, canvas, cur_cam);

  DrawableFactory drawable_factory = new DrawableFactory(renderer);
  GameState draw_state = new GameState(renderer);

  SpriteLoader loader = new SpriteLoader(drawable_factory, input, cur_cam, dialogue);

  draw_state.loadArea("first", "images/sheep_map.json", "images/map_units_sheep.json", loader)
    .then((bool ret)
        {
          gameLoop.state = draw_state;
          draw_state.setVisible("first", true);
        });

  gameLoop.start();
}
