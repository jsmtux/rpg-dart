library game_state;

import 'dart:html';
import 'dart:async';

import 'package:game_loop/game_loop_html.dart';
import 'package:vector_math/vector_math.dart';

import 'drawable.dart';
import 'renderer.dart';
import 'sprite_importer.dart';
import 'game_area.dart';
import 'scene_lights.dart';

class GameState extends SimpleHtmlState
{
  Renderer renderer_;
  SceneLightsController lights_controller_;

  Map<String, GameArea> areas_ = new Map<String, GameArea>();
  List<GameArea> visible_areas_ = new List<GameArea>();
  List<GameArea> updated_areas_ = new List<GameArea>();

  GameState(this.renderer_)
  {
    lights_controller_ = renderer_.getLightsController();
    lights_controller_.SetAmbientLight(new BaseLight(new Vector3(0.7, 0.7, 0.7)));
    lights_controller_.SetDirectionalLight(new DirectionalLight(new Vector3(0.5,-0.3,1.0), new Vector3(0.3,0.3,0.3)));
  }

  Future loadArea(String name, String level_path, String behaviour_path, SpriteLoader loader)
  {
    Completer ret = new Completer();
    GameArea toAdd = new GameArea();
    toAdd.LoadGameArea(level_path, behaviour_path, loader, this).then((bool ok){areas_[name] = toAdd; ret.complete(ok);});
    areas_[name] = toAdd;
    return ret.future;
  }

  void unLoadArea(String name)
  {
    visible_areas_.remove(areas_[name]);
    updated_areas_.remove(areas_[name]);
    areas_.remove(areas_[name]);

  }

  void setVisible(String areaName, bool visible)
  {
    GameArea area = areas_[areaName];
    bool already_visible = visible_areas_.contains(area);
    if (already_visible && !visible || !already_visible && visible)
    {
      visible_areas_.remove(area);
      if (visible)
      {
        if(!visible_areas_.contains(area))
        {
          visible_areas_.add(area);
        }
      }
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
      area.updateBehaviour();
    });
  }

  void onKeyDown(KeyboardEvent event) {
  }
}