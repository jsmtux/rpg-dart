import 'dart:html';

import 'package:game_loop/game_loop_html.dart';

import 'renderer.dart';
import 'game_state.dart';
import 'drawable_factory.dart';
import 'camera.dart';
import 'sprite_importer.dart';
import 'dialogue_box.dart';
import 'input.dart';

class GameManager
{
  CanvasElement canvas_;
  DivElement div_game_area_;
  DivElement div_analog_controller_;
  Input input_;
  GameLoopHtml game_loop_;
  DialogueBox dialogue_;
  Camera camera_;
  Renderer renderer_;
  String current_map_, current_sprites_;

  GameManager()
  {
    canvas_ = querySelector("#game-element");
    div_game_area_ = querySelector("#game-area");
    div_analog_controller_ = querySelector('#analog_control_base');
    game_loop_ = new GameLoopHtml(canvas_);
    game_loop_.pointerLock.lockOnClick = false;
    input_ = new CombinedInput(canvas_, div_analog_controller_, game_loop_.keyboard, game_loop_.mouse);
    dialogue_ = new DialogueBox(querySelector("#dialogue"));
    camera_ = new Camera();
    renderer_ = new Renderer(div_game_area_, canvas_, camera_);
  }

  void startGame(String map, String sprites)
  {
    current_map_ = map;
    current_sprites_ = sprites;
    renderer_.init();

    DrawableFactory drawable_factory = new DrawableFactory(renderer_);
    GameState draw_state = new GameState(renderer_, drawable_factory);

    SpriteLoader loader = new SpriteLoader(drawable_factory, input_, camera_, dialogue_);

    draw_state.loadArea("first", map, sprites, loader)
    .then((bool ret)
    {
      game_loop_.state = draw_state;
      draw_state.setVisible("first", true);
      querySelector('#pause-button').style.display = 'block';
    });

    game_loop_.start();
  }

  void stopGame()
  {
    renderer_.stop();
    game_loop_.stop();
  }

  void restartGame()
  {
    stopGame();
    startGame(current_map_, current_sprites_);
  }
}

AnchorElement addButton(String text, DivElement menu, String button_class)
{
  AnchorElement button = new AnchorElement();
  button.text = text;
  button.classes.add(button_class);
  button.classes.add("btn");
  menu.append(button);
  return button;
}

AnchorElement addMenuButton(String text, DivElement menu) => addButton(text, menu, "menu-button");

AnchorElement addGridButton(String text, DivElement menu) => addButton(text, menu, "grid-button");

main() {
  GameManager game_manager = new GameManager();
  DivElement main_window = querySelector("#main-window");
  DivElement level_window = querySelector("#level-modal");
  DivElement options_window = querySelector("#options-modal");
  DivElement ingame_window = querySelector("#ingame-modal");

  addMenuButton("Start", main_window).onClick.listen((event) => level_window.classes.add("show"));
  AnchorElement options_button = addMenuButton("Options", main_window);

  DivElement pause_button = querySelector('#pause-button');
  pause_button.onClick.listen((event) => ingame_window.classes.add("show"));

  options_button.onClick.listen((event) => options_window.classes.add("show"));
  AnchorElement close_options = options_window.querySelector("#Close-options");
  close_options.onClick.listen((event) => options_window.classes.remove("show"));

  AnchorElement close_ingame = ingame_window.querySelector("#Close-ingame");
  close_ingame.onClick.listen((event) => ingame_window.classes.remove("show"));

  addMenuButton("Restart", ingame_window).onClick.listen((event)
  {
    game_manager.restartGame();
    ingame_window.classes.remove("show");
  });
  addMenuButton("Main menu", ingame_window).onClick.listen((event)
  {
    game_manager.stopGame();
    ingame_window.classes.remove("show");
    querySelector('#pause-button').style.display = 'none';
  });

  AnchorElement close = level_window.querySelector("#Close");
  close.onClick.listen((event) => level_window.classes.remove("show"));
  DivElement level_menu = level_window.querySelector("#level-menu");
  addGridButton("01", level_menu).onClick.listen(
      (event){game_manager.startGame("images/sheep_map.json", "images/map_units_sheep.json"); level_window.classes.remove("show");});
  addGridButton("02", level_menu).onClick.listen(
      (event){game_manager.startGame("images/sheep_2.json", "images/map_units_sheep_2.json"); level_window.classes.remove("show");});
  addGridButton("03", level_menu).onClick.listen(
      (event){game_manager.startGame("images/sheep_3.json", "images/map_units_sheep_3.json"); level_window.classes.remove("show");});
}
