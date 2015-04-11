library game_state;

import 'dart:html';
import 'dart:async';

import 'package:game_loop/game_loop_html.dart';

import 'drawable.dart';
import 'renderer.dart';
import 'behaviour/behaviour.dart';
import 'sprite_importer.dart';
import 'game_area.dart';

class GameState extends SimpleHtmlState
{
  Renderer renderer_;

  Map<String, GameArea> areas_ = new Map<String, GameArea>();
  List<GameArea> visible_areas_ = new List<GameArea>();
  List<GameArea> updated_areas_ = new List<GameArea>();

  Future loadArea(String name, String level_path, String behaviour_path, SpriteLoader loader)
  {
    Completer ret = new Completer();
    GameArea toAdd = new GameArea();
    toAdd.LoadGameArea(level_path, behaviour_path, loader, this).then((bool ok){areas_[name] = toAdd; ret.complete(ok);});
    areas_[name] = toAdd;
    return ret.future;
  }

  void setVisible(String areaName, bool visible)
  {
    GameArea area = areas_[areaName];
    visible_areas_.remove(area);
    if (visible)
    {
      visible_areas_.add(area);
    }
  }

  void onRender(GameLoop gameLoop) {
    List<List<Drawable>> list = new List<List<Drawable>>();
    for(GameArea area in visible_areas_)
    {
      list.add(area.drawables_);
    };
    renderer_.render(list);
  }

  void onUpdate(GameLoop gameLoop)
  {
    areas_.forEach((k, area)
    {
      for (Behaviour behaviour in area.behaviours_)
      {
        behaviour.update(area);
      }
    });
  }

  void onKeyDown(KeyboardEvent event) {
  }

  GameState(Renderer renderer)
  {
    renderer_ = renderer;
  }
}