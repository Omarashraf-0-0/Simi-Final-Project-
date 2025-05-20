abstract class ResourceComponent {
  String get name;
  void add(ResourceComponent component) {}
  void display();
}

class ResourceLeaf extends ResourceComponent {
  final String name;
  final String url;

  ResourceLeaf(this.name, this.url);

  @override
  void display() {
    print('Resource: $name - $url');
  }
}

class ResourceComposite extends ResourceComponent {
  final String name;
  final List<ResourceComponent> children = [];

  ResourceComposite(this.name);

  @override
  void add(ResourceComponent component) {
    children.add(component);
  }

  @override
  void display() {
    print('Category: $name');
    for (final child in children) {
      child.display();
    }
  }
}