library input;

import 'dart:html';

import 'package:game_loop/game_loop_html.dart';
import 'package:vector_math/vector_math.dart';

abstract class Input
{
  static const int X = 0;
  static const int Y = 1;

  static const int ATTACK = 0;
  static const int JUMP = 1;

  bool isDown(int key);

  double getAxis(int axis);
}

class KeyboardInput implements Input
{
  Keyboard keyboard_;

  KeyboardInput(this.keyboard_);

  bool isDown(int key)
  {
    bool ret;
    if (key == Input.ATTACK)
    {
      ret = keyboard_.isDown(Keyboard.SPACE);
    }
    else if (key == Input.JUMP)
    {
      ret = keyboard_.isDown(Keyboard.C);
    }
    return ret;
  }

  double getAxis(int axis)
  {
    double ret = 0.0;
    if(axis == Input.Y)
    {
      if (keyboard_.isDown(Keyboard.UP))
      {
        ret = 1.0;
      }
      else if (keyboard_.isDown(Keyboard.DOWN))
      {
        ret = -1.0;
      }
      if(keyboard_.isDown(Keyboard.LEFT) || keyboard_.isDown(Keyboard.RIGHT))
      {
        ret *= 0.55;
      }
    }
    else if(axis == Input.X)
    {
      if (keyboard_.isDown(Keyboard.RIGHT))
      {
        ret = 1.0;
      }
      else if (keyboard_.isDown(Keyboard.LEFT))
      {
        ret = -1.0;
      }
      if(keyboard_.isDown(Keyboard.UP) || keyboard_.isDown(Keyboard.DOWN))
      {
        ret *= 0.4;
      }
    }
    return ret;
  }
}

class TouchInput implements Input
{
  CanvasElement canvas_;
  DivElement analog_control_base_;
  DivElement analog_control_;
  Vector2 touch_movement_begin_ = new Vector2.zero();
  Vector2 touch_movement_diff_ = new Vector2.zero();
  int touch_movement_id_ = -1;

  TouchInput(this.canvas_, this.analog_control_base_)
  {
    analog_control_ = analog_control_base_.querySelector("#analog_control");
    canvas_.onTouchStart.listen(StartHandler);
    canvas_.onTouchMove.listen(MoveHandler);
    canvas_.onTouchEnd.listen(EndHandler);
  }

  void StartHandler(TouchEvent event)
  {
    event.preventDefault();
    if(touch_movement_id_ == -1)
    {
      analog_control_base_.style.visibility = "visible";
      analog_control_base_.style.left = (event.changedTouches.first.page.x - 25).toString()+"px";
      analog_control_base_.style.top = (event.changedTouches.first.page.y - 25).toString()+"px";
      touch_movement_begin_ = new Vector2(event.changedTouches.first.page.x * 0.1, event.changedTouches.first.page.y * 0.1);
      touch_movement_diff_ = new Vector2.zero();
      touch_movement_id_ = event.changedTouches.first.identifier;
    }
  }

  void MoveHandler(TouchEvent event)
  {
    event.preventDefault();
    TouchList changed_touches = event.changedTouches;
    for (Touch t in changed_touches)
    {
      if (t.identifier == touch_movement_id_)
      {
        touch_movement_diff_ = new Vector2(t.page.x  * 0.1 , t.page.y  * 0.1) - touch_movement_begin_;
        analog_control_.style.left = (touch_movement_diff_.x.floor() + 17).toString()+"px";
        analog_control_.style.top = (touch_movement_diff_.y.floor() + 17).toString()+"px";
      }
    }
  }

  void EndHandler(TouchEvent event)
  {
    event.preventDefault();
    TouchList changed_touches = event.changedTouches;
    for (Touch t in changed_touches)
    {
      if (t.identifier == touch_movement_id_)
      {
        analog_control_base_.style.visibility = "hidden";
        touch_movement_begin_ = new Vector2.zero();
        touch_movement_diff_ = new Vector2.zero();
        touch_movement_id_ = -1;
      }
    }
  }

  bool isDown(int key)
  {
    return false;
  }

  double getAxis(int axis)
  {
    double ret;
    if(axis == Input.X)
    {
      ret = touch_movement_diff_.y;
    }
    else if(axis == Input.Y)
    {
      ret = touch_movement_diff_.x;
    }
    return ret;
  }
}

class CombinedInput implements Input
{
  TouchInput touch_input_;
  KeyboardInput key_input_;

  CombinedInput(CanvasElement canvas, DivElement analog_control, Keyboard keyboard)
  {
    touch_input_ = new TouchInput(canvas, analog_control);
    key_input_ = new KeyboardInput(keyboard);
  }

  bool isDown(int key)
  {
    return touch_input_.isDown(key) || key_input_.isDown(key);
  }
  double getAxis(int axis)
  {
    var ret = touch_input_.getAxis(axis);
    if (ret == 0)
    {
      ret = key_input_.getAxis(axis);
    }
    return ret;
  }
}