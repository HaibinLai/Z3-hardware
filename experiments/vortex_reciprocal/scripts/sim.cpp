#include "VVortexRecipTop.h"
#include "verilated.h"
#include <array>
#include <cstdint>
#include <fstream>
#include <iomanip>
#include <iostream>
#include <string>
#include <limits>

static uint32_t oracle(uint32_t x,bool fixed) {
 const uint32_t e=(x>>23)&255,f=x&0x7fffff,s=x&0x80000000;
 if(e==0)return 0x7f7fffff;
 if(e==255)return f?0x7fc00000:s;
 const uint64_t d=2049+2*(f>>13);uint32_t y=((uint64_t(1)<<43)+d)/(2*d);
 const uint64_t a=uint64_t((1<<23)+f)<<7;
 for(int k=0;k<2;k++){uint32_t p=uint32_t((a*y)>>31),t=uint32_t(0x80000000u-p);y=uint32_t((uint64_t(y)*t)>>30);}
 if(fixed&&e>=253){
  const unsigned sh=e==253?8:9;uint32_t q=y>>sh,r=y&((1u<<sh)-1),half=1u<<(sh-1);
  q+=(r>half)||((r==half)&&(q&1));return s|q;
 }
 const uint32_t dd=uint32_t((uint64_t(y)<<1)-0x80000000ull),fr=((dd>>8)+((dd>>7)&1))&0xffffff;
 const bool carry=fr>>23;return s|(((253-e+uint32_t(carry))&255)<<23)|(carry?0:(fr&0x7fffff));
}

static void tick(VVortexRecipTop&t){t.clk=0;t.eval();t.clk=1;t.eval();t.clk=0;t.eval();}
struct Row{int64_t lo=INT64_MAX,hi=INT64_MIN;uint32_t minx=0,miny=0,maxx=0,maxy=0;uint32_t finite=0,nan=0,inf=0,zero=0;};

int main(int argc,char**argv){
 Verilated::commandArgs(argc,argv);VVortexRecipTop t;t.a=t.b=t.c=0;t.reset=1;tick(t);t.reset=0;
 if(argc<5){std::cerr<<"exhaust PREFIX EXPONENT original|fixed; probes INPUT OUTPUT original|fixed\n";return 1;}
 const std::string mode=argv[1];const bool fixed=std::string(argv[4])=="fixed";
 if(mode=="probes"){
  std::ifstream in(argv[2]);std::ofstream out(argv[3]);uint32_t x;size_t count=0;
  while(in>>std::hex>>x){t.a=x;for(int k=0;k<6;k++)tick(t);uint32_t y=t.result;
   if(y!=oracle(x,fixed)){std::cerr<<"MODEL MISMATCH "<<std::hex<<x<<"\n";return 2;}
   out<<std::hex<<std::setfill('0')<<std::setw(8)<<x<<" "<<std::setw(8)<<y<<"\n";count++;
  }std::cout<<"PROBES "<<count<<" all match\n";return 0;
 }
 if(mode!="exhaust")return 1;
 const std::string prefix=argv[2];const unsigned e=std::stoul(argv[3]);if(e!=127&&e!=253&&e!=254)return 1;
 std::array<Row,1024> rows;std::ofstream binary(prefix+"-outputs.bin",std::ios::binary);uint64_t count=0;
 for(uint32_t i=0;i<(1u<<23)+4;i++){
  t.a=(e<<23)|(i<(1u<<23)?i:0);tick(t);if(i<4)continue;
  const uint32_t f=i-4,x=(e<<23)|f,y=t.result,he=(y>>23)&255,hf=y&0x7fffff;Row&r=rows[f>>13];
  if(y!=oracle(x,fixed)){std::cerr<<"MODEL MISMATCH "<<std::hex<<x<<" "<<y<<"\n";return 2;}
  binary.write(reinterpret_cast<const char*>(&y),4);count++;
  if(he==255){if(hf)r.nan++;else r.inf++;continue;}
  if((y&0x7fffffff)==0)r.zero++;r.finite++;
  const uint64_t a=(1u<<23)+f;uint64_t p;
  if(e==127){if(he!=126&&he!=127)return 3;const uint64_t b=he==127?(1u<<24):(1u<<23)+hf;p=a*b;}
  else {if(he>1)return 3;const uint64_t b=hf+(he?(1u<<23):0);p=(a*b)<<(e-252);}
  const int64_t n=int64_t(p)-int64_t(uint64_t(1)<<47);
  if(n<r.lo){r.lo=n;r.minx=x;r.miny=y;}if(n>r.hi){r.hi=n;r.maxx=x;r.maxy=y;}
 }
 std::ofstream out(prefix+"-partitions.tsv");out<<"index\tmin_numerator\tmax_numerator\tmin_x\tmin_y\tmax_x\tmax_y\tfinite\tnan\tinf\tzero\n";
 uint64_t nonfinite=0;
 for(size_t i=0;i<1024;i++){const Row&r=rows[i];nonfinite+=r.nan+r.inf;out<<std::dec<<i<<"\t";
  if(r.finite)out<<r.lo;out<<"\t";if(r.finite)out<<r.hi;
  out<<"\t"<<std::hex<<std::setfill('0')<<std::setw(8)<<r.minx<<"\t"<<std::setw(8)<<r.miny<<"\t"<<std::setw(8)<<r.maxx<<"\t"<<std::setw(8)<<r.maxy;
  out<<std::dec<<"\t"<<r.finite<<"\t"<<r.nan<<"\t"<<r.inf<<"\t"<<r.zero<<"\n";
 }std::cout<<"EXHAUST "<<(fixed?"fixed":"original")<<" E="<<e<<" inputs="<<count<<" nonfinite="<<nonfinite<<" all model outputs match\n";
 return 0;
}
