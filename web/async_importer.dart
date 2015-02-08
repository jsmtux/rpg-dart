library async_importer;

import "dart:html";
import "dart:async";

abstract class AsyncImporter<T>
{
  Future RequestFile(String path)
  {
    return HttpRequest.getString(path).then((res) => processFile(res));
  }

  T processFile(String path);
}