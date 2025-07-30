#include "matlab_lexer.h"
#include "matlab_parser.h"
#include <fstream>

int main(int argc, char *argv[]) {
    if (argc < 2) {
        std::cerr << "Usage: " << argv[0] << " <matlab_file.m>" << std::endl;
        return 1;
    }

    std::ifstream in(argv[1]);
    if (!in) {
        std::cerr << "Cannot open file: " << argv[1] << std::endl;
        return 1;
    }

    MatlabLexer lexer(in);
    matlab::parser parser(lexer);
    
    return parser.parse();
}
