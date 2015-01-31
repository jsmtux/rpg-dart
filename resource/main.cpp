#include <string>
#include <vector>
#include <iostream>
#include <ios>
#include <iomanip>
using namespace std;

#include <assimp/Importer.hpp>
#include <assimp/scene.h>
#include <assimp/postprocess.h>

class Identation
{
public:
	Identation()
	{
		cur_ = 0;
	}
	string retCurrent() const
	{
		string ret;
		for(int i = 0; i < cur_; i++)
		{
			ret += "  ";
		}
		return ret;
	}
	void add()
	{
		cur_++;
	}
	void substract()
	{
		cur_--;
	}
private:
	int cur_;
};

ostream& operator<<(ostream& os, const Identation& id)
{
    os << id.retCurrent();
    return os;
}

class JsonClass
{
public:
	JsonClass(Identation &id)
		: id_(id)
	{
		cout << id_ << "{\n";
		id.add();
	}
	~JsonClass()
	{
		id_.substract();
		cout << id_ << "}\n";
	}
private:
	Identation &id_;
};

class JsonArray
{
public:
	JsonArray(Identation &id)
		: id_(id)
	{
		cout << id_ << "[\n";
		id.add();
	}
	~JsonArray()
	{
		id_.substract();
		cout << id_ << "]\n";
	}
private:
	Identation &id_;
};

int main(int argc, char** argv)
{
	if (argc != 2)
	{
		cout << "Usage " << argv[0] << " <file path>" << std::endl;
	}
	else
	{
		string path;

		Assimp::Importer importer;
		const aiScene* scene = importer.ReadFile(argv[1], aiProcess_Triangulate | aiProcess_GenSmoothNormals | aiProcess_FlipUVs);
	
		if(!scene)
		{
			cerr << "Error loading " << path << endl;
		}
	
		Identation id;
		JsonClass root(id);
	
		cout << id << "\"meshes\":\n";
		{
			JsonArray meshes(id);
			for (int i = 0; i < scene->mNumMeshes; i++)
			{
				if (i != 0)
				{
					cout << ",";
				}
				JsonClass mesh_class(id);
				const aiMesh* mesh = scene->mMeshes[i];
				cout << id << "\"material_index\": " << mesh->mMaterialIndex << "," << std::endl;
				cout << id << "\"vertices\" :\n";
				{
					vector<float> vertices;
					vector<float> textures;
					for (int j = 0; j < mesh->mNumVertices; j++)
					{
						vertices.push_back(mesh->mVertices[j].x);
						vertices.push_back(mesh->mVertices[j].y);
						vertices.push_back(mesh->mVertices[j].z);
						if (mesh->HasTextureCoords(0))
						{
							textures.push_back(mesh->mTextureCoords[0][j].x);
							textures.push_back(mesh->mTextureCoords[0][j].y);
						}
					}
					std::cout << std::setprecision(4) << std::fixed;
					JsonArray json_vertices(id);
					{
						JsonArray json_positions(id);
						cout << id;
		
						for (unsigned int j = 0; j < vertices.size(); j++)
						{
							if (j != 0)
							{
								 cout << ", ";
							}
							cout << vertices[j];
						}
						cout << endl;
					}
					cout << ",";
					{
						JsonArray json_textures(id);
						cout << id;
		
						for (unsigned int j = 0; j < textures.size(); j++)
						{
							if (j != 0)
							{
								 cout << ", ";
							}
							cout << textures[j];
						}
						cout << endl;
					}
				}
				std::cout << std::setprecision(0) << std::fixed;
				
				cout << id << ",\"indices\" : \n";
				{
					JsonArray indices(id);
					for (unsigned int j = 0 ; j < mesh->mNumFaces ; j++) {
						const aiFace& Face = mesh->mFaces[j];
						cout << id;
						if (j != 0)
						{
							cout << ",";
						}
						cout << Face.mIndices[0] << "," << Face.mIndices[1] << "," << Face.mIndices[2] << std::endl;
					}
				}
			}
		}
	
		cout << id << ",\"materials\":\n";
		{
			JsonArray materials(id);
			for (int i = 0; i < scene->mNumMaterials; i++)
			{
				const aiMaterial* material = scene->mMaterials[i];
				if (material->GetTextureCount(aiTextureType_DIFFUSE) > 0) {
				    aiString Path;
					if (i != 0)
					{
						cout << ", ";
					}
				    if (material->GetTexture(aiTextureType_DIFFUSE, 0, &Path, NULL, NULL, NULL, NULL, NULL) == AI_SUCCESS) {
					cout << "\"" << Path.data << "\"";
				    }
				}
			}
		}
	}
	return 0;
}
