
#include "marian.h"
#include "mnist.h"

using namespace std;

int main(int argc, char** argv) {
  /*int numImg = 0;*/
  /*auto images = datasets::mnist::ReadImages("../examples/mnist/t10k-images-idx3-ubyte", numImg);*/
  /*auto labels = datasets::mnist::ReadLabels("../examples/mnist/t10k-labels-idx1-ubyte", numImg);*/

  using namespace marian;
  using namespace keywords;
  
  const size_t IMAGE_SIZE = 784;
  const size_t LABEL_SIZE = 10;

  Expr x = input(shape={whatevs, IMAGE_SIZE}, name="X");
  Expr y = input(shape={whatevs, LABEL_SIZE}, name="Y");
  
  Expr w = param(shape={IMAGE_SIZE, LABEL_SIZE}, name="W0");
  Expr b = param(shape={1, LABEL_SIZE}, name="b0");
  
  Expr scores = dot(x, w) + b;
  Expr lr = softmax(scores, axis=1, name="pred");
  Expr graph = -mean(sum(y * log(lr), axis=1), axis=0, name="cost");
  cerr << "lr=" << Debug(lr.val().shape()) << endl;

  int numofdata;
  vector<float> images = datasets::mnist::ReadImages("../examples/mnist/t10k-images-idx3-ubyte", numofdata, IMAGE_SIZE);
  vector<float> labels = datasets::mnist::ReadLabels("../examples/mnist/t10k-labels-idx1-ubyte", numofdata, LABEL_SIZE);
  cerr << "images=" << images.size() << " labels=" << labels.size() << endl;
  cerr << "numofdata=" << numofdata << endl;

  Tensor tx({numofdata, IMAGE_SIZE}, 1);
  Tensor ty({numofdata, LABEL_SIZE}, 1);

  tx.Load(images);
  ty.Load(labels);

  cerr << "tx=" << Debug(tx.shape()) << endl;
  cerr << "ty=" << Debug(ty.shape()) << endl;

  x = tx;
  y = ty;

  graph.forward(500);

  std::cerr << "scores: " << Debug(scores.val().shape()) << endl;
  std::cerr << "lr: " << Debug(lr.val().shape()) << endl;
  std::cerr << "Log-likelihood: " << Debug(graph.val().shape()) << endl ;

  std::cerr << "scores=" << scores.val().Debug() << endl;

  graph.backward();
  
  //std::cerr << graph["pred"].val()[0] << std::endl;
  

   // XOR
  /*
  Expr x = input(shape={whatevs, 2}, name="X");
  Expr y = input(shape={whatevs, 2}, name="Y");

  Expr w = param(shape={2, 1}, name="W0");
  Expr b = param(shape={1, 1}, name="b0");

  Expr n5 = dot(x, w);
  Expr n6 = n5 + b;
  Expr lr = softmax(n6, axis=1, name="pred");
  cerr << "lr=" << lr.Debug() << endl;

  Expr graph = -mean(sum(y * log(lr), axis=1), axis=0, name="cost");

  Tensor tx({4, 2}, 1);
  Tensor ty({4, 1}, 1);
  cerr << "tx=" << tx.Debug() << endl;
  cerr << "ty=" << ty.Debug() << endl;

  tx.Load("../examples/xor/train.txt");
  ty.Load("../examples/xor/label.txt");
  */

#if 0  
  hook0(graph);
  graph.autodiff();
  std::cerr << graph["cost"].val()[0] << std::endl;
  //hook1(graph);
  for(auto p : graph.params()) {
    auto update = _1 = _1 - alpha * _2;
    Element(update, p.val(), p.grad());
  }
  hook2(graph);
  
  auto opt = adadelta(cost_function=cost,
                      eta=0.9, gamma=0.1,
                      set_batch=set,
                      before_update=before,
                      after_update=after,
                      set_valid=valid,
                      validation_freq=100,
                      verbose=1, epochs=3, early_stopping=10);
  opt.run();
#endif  
  return 0;
}
