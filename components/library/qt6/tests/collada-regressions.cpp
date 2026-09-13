// SPDX-License-Identifier: CDDL-1.0
#include "AssetLib/Collada/ColladaParser.h"
#include <assimp/DefaultIOSystem.h>
#include <assimp/cimport.h>
#include <assimp/scene.h>
#include <climits>
#include <iostream>
#include <stdexcept>

static void check(bool ok, const char *message) {
    if (!ok)
        throw std::runtime_error(message);
}

int main(int argc, char **argv) {
    try {
        check(argc == 2, "fixture argument required");
        Assimp::DefaultIOSystem io;
        Assimp::ColladaParser parser(&io, argv[1]);
        for (unsigned int offset : {0u, 3u, UINT_MAX}) {
            pugi::xml_document doc;
            auto node = doc.append_child("input");
            node.append_attribute("semantic") = "VERTEX";
            node.append_attribute("source") = "#positions";
            node.append_attribute("offset") = offset;
            std::vector<Assimp::Collada::InputChannel> channels;
            parser.ReadInputChannel(node, channels);
            check(channels.size() == 1, "missing input channel");
            check(channels[0].mOffset == static_cast<size_t>(offset), "offset width/word corruption");
        }
        for (const char *semantic : {"TEXCOORD", "COLOR", "UNKNOWN"}) {
            pugi::xml_document doc;
            auto node = doc.append_child("instance_material");
            auto binding = node.append_child("bind_vertex_input");
            binding.append_attribute("semantic") = "diffuse_uv";
            binding.append_attribute("input_semantic") = semantic;
            binding.append_attribute("input_set") = 1u;
            Assimp::Collada::SemanticMappingTable table;
            parser.ReadMaterialVertexInputBinding(node, table);
            const auto &entry = table.mMap.at("diffuse_uv");
            auto expected = std::string(semantic) == "TEXCOORD" ? Assimp::Collada::IT_Texcoord
                : std::string(semantic) == "COLOR" ? Assimp::Collada::IT_Color : Assimp::Collada::IT_Invalid;
            check(entry.mType == expected, "material input semantic was not decoded");
            check(entry.mSet == 1u, "material input set was lost");
            binding.remove_attribute("input_set");
            table.mMap.clear();
            parser.ReadMaterialVertexInputBinding(node, table);
            check(table.mMap.at("diffuse_uv").mSet == 0u, "absent input set must default to zero");
        }
        const aiScene *scene = aiImportFile(argv[1], 0);
        check(scene != nullptr, aiGetErrorString());
        check(scene->mNumMeshes == 1, "triangle mesh missing");
        const aiMesh *mesh = scene->mMeshes[0];
        check(mesh->mNumVertices == 3 && mesh->mNumFaces == 1, "triangle indices were corrupted");
        check(mesh->mVertices[1].x == 1.0f && mesh->mVertices[2].y == 1.0f, "vertex offset decoding failed");
        check(mesh->HasTextureCoords(0) && mesh->mTextureCoords[0][0].y == 1.0f && mesh->mTextureCoords[0][1].x == 0.0f, "texture offset decoding failed");
        aiReleaseImport(scene);
        std::cout << "Collada offsets, semantic names, input sets and import passed\n";
        return 0;
    } catch (const std::exception &error) {
        std::cerr << error.what() << '\n';
        return 1;
    }
}
