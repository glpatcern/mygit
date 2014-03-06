#include <iostream>

class MyFunctor {
public:
  void operator()() {
    std::cout << "Hello from cool functor" << std::endl;
  }
};

void hello() {
  std::cout << "Hello from boring C function" << std::endl;
}

template<typename T> void funny(T func) {
  func();
}

int main(int argc, char **argv) {
  MyFunctor myFunctor;

  funny(hello);
  funny(myFunctor);

  return(0);
}
