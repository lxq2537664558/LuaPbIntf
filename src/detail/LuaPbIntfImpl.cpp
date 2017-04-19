#include "LuaPbIntfImpl.h"

#include <google/protobuf/compiler/importer.h>  // for DiskSourceTree

#include <sstream>  // for ostringstream

// See CommandLineInterface::Run().

class ErrorCollector : public google::protobuf::compiler::MultiFileErrorCollector
{
public:
    void Clear() { m_sError.clear(); }
    const std::string& GetError() const { return m_sError; }

    // Only record the last error.
    void AddError(const std::string & filename,
        int line, int column, const std::string & message) override
    {
        std::ostringstream oss;
        oss << filename << ":" << line << ": " << message;
        m_sError = oss.str();
    }
private:
    std::string m_sError;
};

LuaPbIntfImpl::LuaPbIntfImpl()
    : m_pDiskSourceTree(new DiskSourceTree),  // unique_ptr
    m_pErrorCollector(new ErrorCollector),  // unique_ptr
    m_pImporter(new Importer(m_pDiskSourceTree.get(),  // unique_ptr
        m_pErrorCollector.get()))
{
}

LuaPbIntfImpl::~LuaPbIntfImpl()
{
}

// e.g. AddProtoPath("proto")
// e.g. AddProtoPath("d:/proto")
void LuaPbIntfImpl::AddProtoPath(const string& sProtoPath)
{
    MapPath("", sProtoPath);
}

void LuaPbIntfImpl::MapPath(
    const string& sVirtualPath,
    const string& sDiskPath)
{
    m_pDiskSourceTree->MapPath(sVirtualPath, sDiskPath);
}

// e.g. CompileProtoFile("bar/foo.proto")
std::tuple<bool, std::string>
LuaPbIntfImpl::CompileProtoFile(const string& sProtoFile)
{
    m_pErrorCollector->Clear();
    const google::protobuf::FileDescriptor* desc =
        m_pImporter->Import(sProtoFile);
    if (desc) return std::make_tuple(true, "");
    return std::make_tuple(false, "Proto file compile error: "
        + m_pErrorCollector->GetError());
}
