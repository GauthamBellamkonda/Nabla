#ifndef AST_H
#define AST_H

#include <iostream>
#include <cstring>
#include <vector>
#include <memory>
#include <optional>

#include <llvm/IR/Value.h>
#include <llvm/IR/IRBuilder.h>
#include <llvm/IR/Module.h>
#include <llvm/IR/Type.h>
#include <llvm/IR/LLVMContext.h>

using namespace llvm;

static LLVMContext TheContext;
static IRBuilder<> Builder(TheContext);
static std::unique_ptr<Module> TheModule;
static std::map<std::string, Value*> NamedValues;

class Parent
{
public:
    void func();
    class Parent *child;
    virtual llvm::Value *codegen() = 0;
};

class Child : public Parent
{
public:
    void func();
};

// Abstract Node class
class Node;

// Start Class
class Start;

// Classes that are a part of the Declare Section
class Decl;
enum class GradSpecifier
{
    CNS,
    VAR
};
enum class TypeSpecifier
{
    CHAR,
    INT,
    FLOAT,
    BOOL,
    TENSOR
};
class ConstValue;
class InitDeclarator;
class Declarator;
class Initializer;

// Operations class
class AssgnStmt;
enum class LibFuncs
{
    SIN,
    COS,
    LOG,
    EXP
};
enum AssignmentOperator
{
    AST_ASSIGN, // only =
    AST_ADD_ASSIGN,
    AST_SUB_ASSIGN,
    AST_MUL_ASSIGN,
    AST_DIV_ASSIGN,
    AST_AT_ASSIGN
};
class Expr;
class BinaryExpr;
class UnaryExpr;

// Gradient class
class GradStmt;
enum class GradType
{
    GRAD,
    BACKWARD
};

class Node
{
public:
    Node();
    virtual ~Node() = default;
    virtual llvm::Value *codegen() = 0;


    // virtual llvm::Value *codegen() = 0;
    // virtual void print() = 0;
    // int row_num, col_num;
    // add codegen() function from llvm for IR gen
};

// Start Class stores the pointers to all the declarations, expressions and gradients
class Start : public Node
{
public:
    std::vector<class Decl *> *DeclList;
    std::vector<class AssgnStmt *> *AssgnStmtList;
    std::vector<class GradStmt *> *GradStmtList;
    Start(std::vector<class Decl *> *DeclList, std::vector<class AssgnStmt *> *AssgnStmtList, std::vector<class GradStmt *> *GradStmtList);
    virtual ~Start() = default;
    llvm::Value *codegen() override;
};

// Decl Class stores the declarations of a variable such as their gradient specifier, data type and the pointer to the initializer
// It also stores the initial value of the variable if it is initialized
class Decl : public Node
{
public:
    GradSpecifier GradType;
    TypeSpecifier DataType;
    InitDeclarator *InitDeclaratorList;
    Decl(GradSpecifier, TypeSpecifier, InitDeclarator *);
    virtual ~Decl() = default;
    llvm::Value *codegen() override;
};

// InitDeclarator Class stores the pointer to the declarator and the pointer to the initializer
class InitDeclarator : public Node
{
public:
    Declarator *declarator;
    Initializer *initializer;
    InitDeclarator(Declarator *, Initializer *);
    virtual ~InitDeclarator() = default;
    llvm::Value *codegen() override;
};

// Declarator Class stores the name of the variable and the dimensions of the variable
class Declarator : public Node
{
public:
    std::string name;
    std::vector<int> Dimensions;
    Declarator(std::string);
    virtual ~Declarator() = default;
    llvm::Value *codegen() override;
};

class ConstValue : public Node
{
public:
    union inbuilt_type
    {
        int int_val;
        float float_val;
    };
    inbuilt_type value;
    bool isInt;
    // ConstValue(int value, bool isInt = false);
    ConstValue(int value);
    ConstValue(float value);
    virtual ~ConstValue() = default;
    llvm::Value *codegen() override;
};

// Initializer Class stores the value of the variable using a union structure
// It also stores the pointers to the initializers of the elements of the variable if it is an array
class Initializer : public Node
{
public:
    union type_value
    {
        ConstValue *cvalue;
        std::vector<Initializer *> *InitializerList;
        constexpr type_value() : cvalue(nullptr) {}
        ~type_value() {}
    };
    type_value val;
    bool isScalar;
    Initializer(ConstValue *value);
    Initializer(std::vector<Initializer *> *InitializerList);
    // Initializer(ConstValue*, std::vector<Initializer*>);

    void printInitializerList();
    virtual ~Initializer() = default;
    llvm::Value *codegen() override;
};

/* 
Value* Initializer::codegen()
{
    if (isScalar)
    {
        return val.cvalue->codegen();
    }
    else
    {
        std::vector<Value *> values;
        for (auto &initializer : *val.InitializerList)
        {
            values.push_back(initializer->codegen());
        }
        return ConstantArray::get(ArrayType::get(Type::getFloatTy(TheContext), values.size()), values);
    }
} */

// Operations
class AssgnStmt : public Node
{
public:
    // Declarator *declarator;
    // Initializer *initializer;
    // AssgnStmt(Declarator*, Initializer*);
    std::string name;
    std::optional<AssignmentOperator> op;
    Expr *expr;
    AssgnStmt(std::string, std::optional<AssignmentOperator>, Expr *);
    virtual ~AssgnStmt() = default;
    llvm::Value *codegen() override;    
};

class Expr : public Node
{
public:
    Expr();
    virtual void printExpression();
    virtual ~Expr() = default;
    virtual llvm::Value *codegen() = 0;
};

class BinaryExpr : public Expr
{
public:
    Expr *lhs, *rhs;
    char op;
    BinaryExpr(Expr *lhs, Expr *rhs, char op);
    virtual ~BinaryExpr() = default;
    virtual void printExpression();
    llvm::Value *codegen() override;
};

class UnaryExpr : public Expr
{
public:
    Expr *expr;
    std::string identifier;
    ConstValue *cvalue;
    std::optional<LibFuncs> libfunc;

    UnaryExpr(Expr *expr, std::optional<LibFuncs> libfunc, std::string identifier, ConstValue *cvalue);
    virtual ~UnaryExpr() = default;
    virtual void printExpression();
    llvm::Value *codegen() override;
};

// Gradient
class GradStmt : public Node
{
public:
    // Declarator *declarator;
    // Initializer *initializer;
    // GradStmt(Declarator*, Initializer*);
    GradType grad_type;
    std::string name;
    GradStmt(GradType, std::string);
    virtual ~GradStmt() = default;
    llvm::Value *codegen() override;
};

#endif