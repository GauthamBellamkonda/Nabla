#ifndef CODEGEN_H
#define CODEGEN_H

#include "../ast/ast.h"

#include <iostream>

#include <llvm/IR/IRBuilder.h>
#include <llvm/IR/Module.h>
#include <llvm/IR/Type.h>
#include <llvm/IR/LLVMContext.h>


using namespace llvm;

static LLVMContext TheContext;
static IRBuilder<> Builder(TheContext);
static std::unique_ptr<Module> TheModule;
static std::map<std::string, Value *> NamedValues;



#endif // CODEGEN_H