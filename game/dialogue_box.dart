library dialogue_box;

import 'dart:html';

abstract class TextOutput
{
  void setVisible(bool visible);
  void setText(String text);
}

class DialogueBox implements TextOutput
{
  DivElement div_;
  DivElement text_div_;
  AnchorElement close_div_;

  DialogueBox(this.div_)
  {
    text_div_ = div_.querySelector("#dialogue-text");
    close_div_ = div_.querySelector("#dialogue-close");
    close_div_.onClick.listen((event) => print("click"));
  }

  void setVisible(bool visible)
  {
    if (visible)
    {
      div_.style.visibility = "visible";
    }
    else
    {
      div_.style.visibility = "hidden";
    }
  }

  void setText(String text)
  {
    text_div_.text = text;
  }
}
