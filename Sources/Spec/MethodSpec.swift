//
//  MethodSpec.swift
//  SwiftPoet
//
//  Created by Kyle Dorman on 11/11/15.
//
//

import Foundation

public class MethodSpec: PoetSpecImpl {
    public let typeVariables: [TypeName]
    public let throwsError: Bool
    public let returnType: TypeName?
    public let parameters: [ParameterSpec]
    public let code: CodeBlock?
    public var parentType: Construct?
    //    public let defaultValue: CodeBlock?

    private init(b: MethodSpecBuilder) {
        self.typeVariables = b.typeVariables
        self.throwsError = b.throwsError
        self.returnType = b.returnType
        self.parameters = b.parameters
        self.code = b.code
        self.parentType = b.parentType

        super.init(name: b.name, construct: b.construct, modifiers: b.modifiers, description: b.description, imports: b.imports)
    }

    public static func builder(name: String) -> MethodSpecBuilder {
        return MethodSpecBuilder(name: name)
    }

    public override func collectImports() -> Set<String> {
        var collectedImports: [Set<String>] = Array(arrayLiteral: imports)
        typeVariables.forEach { collectedImports.append($0.collectImports()) }
        parameters.forEach { collectedImports.append($0.collectImports()) }

        if let returnType = returnType {
            collectedImports.append(returnType.collectImports())
        }

        return collectedImports.reduce(Set<String>()) { (var dict, set) in
            set.forEach { dict.insert($0) }
            return dict
        }
    }

    public override func emit(codeWriter: CodeWriter, asFile: Bool = false) -> CodeWriter {
        guard let parentType = parentType else {
            emitGeneralFunction(codeWriter)
            return codeWriter
        }

        switch parentType {
        case .Protocol:
            emitFunctionSigniture(codeWriter)
        default:
            emitGeneralFunction(codeWriter)
        }

        return codeWriter
    }

    private func emitGeneralFunction(codeWriter: CodeWriter) {
        emitFunctionSigniture(codeWriter)
        codeWriter.emit(.BeginStatement)
        if let code = code {
            codeWriter.emit(code)
        }
        codeWriter.emit(.EndStatement)
    }

    private func emitFunctionSigniture(codeWriter: CodeWriter) {
        codeWriter.emitDocumentation(self)
        codeWriter.emitModifiers(modifiers)

        let cbBuilder = CodeBlock.builder()
        if name != "init" {
            cbBuilder.addEmitObject(.Literal, any: construct)
        }
        cbBuilder.addEmitObject(.Literal, any: name)
        cbBuilder.addEmitObject(.Literal, any: "(")
        codeWriter.emit(cbBuilder.build())

        var first = true
        parameters.forEach { p in
            if !first {
                codeWriter.emit(.Literal, any: ", ")
            }
            p.emit(codeWriter)
            first = false
        }

        codeWriter.emit(.Literal, any: ")")

        if throwsError {
            codeWriter.emit(.Literal, any: " throws")
        }

        if let returnType = returnType {
            let returnBuilder = CodeBlock.builder()
            returnBuilder.addEmitObject(.Literal, any: " ->")
            returnBuilder.addEmitObject(.Literal, any: returnType)
            codeWriter.emit(returnBuilder.build())
        }
    }
}

public class MethodSpecBuilder: SpecBuilderImpl, Builder {
    public typealias Result = MethodSpec
    public static let defaultConstruct: Construct = .Method

    private var typeVariables = [TypeName]()
    private var throwsError = false
    private var returnType: TypeName?
    private var parameters = [ParameterSpec]()
    private var code: CodeBlock?

    private var _parentType: Construct?
    public var parentType: Construct? {
        return _parentType
    }

    //    public let defaultValue: CodeBlock?

    private init(name: String) {
        let methodName = name == "init" ? name : PoetUtil.cleanCammelCaseString(name)
        super.init(name: methodName, construct: MethodSpecBuilder.defaultConstruct)
    }

    public func build() -> Result {
        return MethodSpec(b: self)
    }

}

// MARK: Add method spcific info
extension MethodSpecBuilder {

    public func addTypeVariable(type: TypeName) -> Self {
        PoetUtil.addDataToList(type, list: &typeVariables)
        return self
    }

    public func addTypeVariables(types: [TypeName]) -> Self {
        types.forEach { addTypeVariable($0) }
        return self
    }

    public func addReturnType(type: TypeName) -> Self {
        returnType = type
        return self
    }

    public func addParameter(parameter: ParameterSpec) -> Self {
        PoetUtil.addDataToList(parameter, list: &parameters)
        return self
    }

    public func addParameters(parameters: [ParameterSpec]) -> Self {
        parameters.forEach { addParameter($0) }
        return self
    }

    public func addCode(code: CodeBlock) -> Self {
        self.code = CodeBlock.builder().addCodeBlock(code).build()
        return self
    }

    public func addParentType(type: Construct) -> Self {
        _parentType = type
        return self
    }

    public func canThrowError() -> Self {
        throwsError = true
        return self
    }

    //    public func addStatement(format: String, args: [AnyObject]) {
    //        code.addStatement(format, args)
    //    }
}

// MARK: Chaining
extension MethodSpecBuilder {

    public func addModifier(m: Modifier) -> Self {
        super.addModifier(internalModifier: m)
        return self
    }

    public func addModifiers(modifiers: [Modifier]) -> Self {
        super.addModifiers(modifiers)
        return self
    }

    public func addDescription(description: String?) -> Self {
        super.addDescription(description)
        return self
    }

    public func addImport(imprt: String) -> Self {
        super.addImport(imprt)
        return self
    }

    public func addImports(imports: [String]) -> Self {
        super.addImports(imports)
        return self
    }
}
