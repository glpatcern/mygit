#include <iostream>

class Top {
public:
  int m_a;

  Top(int a) : m_a(a) {};
  
  ~Top() {};
  
  virtual void print() {
    std::cout << "Top: a = " << m_a << std::endl;
  }  
};

class Child : public Top {
public:
  Child(int a) : Top(a) {};
 
  ~Child() {};
  
  virtual void print() {
    std::cout << "Child: a = " << m_a << std::endl;
  }
  
  virtual void method() {
    std::cout << "Method only defined in Child" << std::endl;
  }
};

template<class C> Templ : public C {
public:
  int m_b;

  Templ(int a, int b) : C(a), m_b(b) {};
  
  ~Templ() {};
  
  virtual void anotherMethod() {
    std::cout << "Another method only defined in Templ" << std::endl;
  }
}

typedef Templ<Top> TTop;

typedef Templ<Child> TChild;

int main() {
  Top t(1);
  t.print();
  Child c(2);
  c.print();
  c.method();
  TTop tt(1, 1);
  tt.print();
  tt.anotherMethod();
  TChild tc(2, 2);
  tc.print();
  tc.method();
  tc.anotherMethod();
}
