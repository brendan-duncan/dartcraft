import 'transform.dart';

class SceneObject extends Transform {
  String name;
  bool active;
  //Mesh? mesh;
  //MeshData? meshData;
  //Material? material;

  SceneObject(this.name, [Transform? parent])
    : active = true
    , super(parent);
}
