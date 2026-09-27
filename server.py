import uuid
import io
import os
import re
import subprocess
import shutil
from flask import Flask, request, send_file
from flask_cors import CORS

app = Flask(__name__)
CORS(app)

def hex_to_vec3(hex_str, multiplier=1.0):
    hex_str = hex_str.lstrip('#')
    if len(hex_str) != 6:
        return f"vec3({1.0 * multiplier:.2f},{1.0 * multiplier:.2f},{1.0 * multiplier:.2f})"
    r = int(hex_str[0:2], 16) / 255.0
    g = int(hex_str[2:4], 16) / 255.0
    b = int(hex_str[4:6], 16) / 255.0
    return f"vec3({r * multiplier:.3f},{g * multiplier:.3f},{b * multiplier:.3f})"

@app.route('/compile_bin', methods=['POST'])
def compile_bin():
    data = request.json
    morning = data.get('morning', '#FFB6C1')
    noon = data.get('noon', '#87CEEB')
    evening = data.get('evening', '#FFA500')
    night = data.get('night', '#00008B')
    rayColor = data.get('rayColor', '#FAFCFF')
    fogColor = data.get('fogColor', '#C0BCE6')
    waterColor = data.get('waterColor', '#4287F5')
    lightIntensity = float(data.get('lightIntensity', 1.0))
    waterQuality = data.get('waterQuality', 'Ultra')
    shadowFidelity = data.get('shadowFidelity', 'Soft Shadows')
    cloudType = data.get('cloudType', 'Realistic 3D')
    wavingFoliage = data.get('wavingFoliage', True)
    packName = data.get('packName', 'Piglix Shader')
    
    # 1. Create a unique workspace for this specific user's request
    req_id = str(uuid.uuid4())
    workspace_dir = f'temp_workspace_{req_id}'
    
    try:
        # Copy the base source code to the unique workspace
        shutil.copytree('newb-source', workspace_dir)
        
        # Edit pack_config.toml for custom pack name
        toml_path = os.path.join(workspace_dir, 'src/newb/pack_config.toml')
        if os.path.exists(toml_path):
            with open(toml_path, 'r') as f:
                toml_content = f.read()
            toml_content = re.sub(r'^name\s*=\s*".*?"', f'name = "{packName}"', toml_content, flags=re.MULTILINE)
            with open(toml_path, 'w') as f:
                f.write(toml_content)
        
        config_path = os.path.join(workspace_dir, 'src/newb/config.h')
        
        with open(config_path, 'r') as f:
            content = f.read()
        
        # Inject colors
        content = re.sub(r'#define NL_DAWN_ZENITH_COL\s+vec3\(.*?\)', f'#define NL_DAWN_ZENITH_COL   {hex_to_vec3(morning, 0.8)}', content)
        content = re.sub(r'#define NL_DAWN_HORIZON_COL\s+vec3\(.*?\)', f'#define NL_DAWN_HORIZON_COL  {hex_to_vec3(morning, 1.5)}', content)
        content = re.sub(r'#define NL_DAWN_EDGE_COL\s+vec3\(.*?\)', f'#define NL_DAWN_EDGE_COL     {hex_to_vec3(morning, 2.5)}', content)
        
        content = re.sub(r'#define NL_DAY_ZENITH_COL\s+vec3\(.*?\)', f'#define NL_DAY_ZENITH_COL    {hex_to_vec3(noon, 0.7)}', content)
        content = re.sub(r'#define NL_DAY_HORIZON_COL\s+vec3\(.*?\)', f'#define NL_DAY_HORIZON_COL   {hex_to_vec3(noon, 1.1)}', content)
        content = re.sub(r'#define NL_DAY_EDGE_COL\s+vec3\(.*?\)', f'#define NL_DAY_EDGE_COL      {hex_to_vec3(noon, 1.3)}', content)
        
        content = re.sub(r'#define NL_DUSK_ZENITH_COL\s+vec3\(.*?\)', f'#define NL_DUSK_ZENITH_COL   {hex_to_vec3(evening, 0.6)}', content)
        content = re.sub(r'#define NL_DUSK_HORIZON_COL\s+vec3\(.*?\)', f'#define NL_DUSK_HORIZON_COL  {hex_to_vec3(evening, 1.8)}', content)
        content = re.sub(r'#define NL_DUSK_EDGE_COL\s+vec3\(.*?\)', f'#define NL_DUSK_EDGE_COL     {hex_to_vec3(evening, 2.8)}', content)
        
        content = re.sub(r'#define NL_NIGHT_ZENITH_COL\s+vec3\(.*?\)', f'#define NL_NIGHT_ZENITH_COL  {hex_to_vec3(night, 0.1)}', content)
        content = re.sub(r'#define NL_NIGHT_HORIZON_COL\s+vec3\(.*?\)', f'#define NL_NIGHT_HORIZON_COL {hex_to_vec3(night, 0.2)}', content)
        content = re.sub(r'#define NL_NIGHT_EDGE_COL\s+vec3\(.*?\)', f'#define NL_NIGHT_EDGE_COL    {hex_to_vec3(night, 0.4)}', content)
        
        # Global Tints
        content = re.sub(r'#define NL_DAWN_SUNLIGHT_COL\s+vec3\(.*?\)', f'#define NL_DAWN_SUNLIGHT_COL   {hex_to_vec3(rayColor, 1.4)}', content)
        content = re.sub(r'#define NL_NOON_SUNLIGHT_COL\s+vec3\(.*?\)', f'#define NL_NOON_SUNLIGHT_COL   {hex_to_vec3(rayColor, 1.4)}', content)
        content = re.sub(r'#define NL_DUSK_SUNLIGHT_COL\s+vec3\(.*?\)', f'#define NL_DUSK_SUNLIGHT_COL   {hex_to_vec3(rayColor, 1.4)}', content)
        content = re.sub(r'#define NL_WATER_TINT\s+vec3\(.*?\)', f'#define NL_WATER_TINT {hex_to_vec3(waterColor, 1.0)}', content)
        content = re.sub(r'#define NL_TINT_LOW\s+vec3\(.*?\)', f'#define NL_TINT_LOW  {hex_to_vec3(fogColor, 1.0)}', content)
        content = re.sub(r'#define NL_TINT_HIGH\s+vec3\(.*?\)', f'#define NL_TINT_HIGH {hex_to_vec3(fogColor, 1.2)}', content)
        
        # Inject Pro Settings
        new_config = "\n// --- PRO SETTINGS OVERRIDES ---\n"
        new_config += f"#undef NL_SUNLIGHT_INTENSITY\n#define NL_SUNLIGHT_INTENSITY {3.2 * lightIntensity:.2f}\n"
        if not wavingFoliage:
            new_config += "#undef NL_PLANTS_WAVE\n"
        if waterQuality == 'Low':
            new_config += "#undef NL_WATER_WAVE\n#undef NL_WATER_BUMP\n"
        if 'Hard' in shadowFidelity:
            new_config += "#undef NL_SHADOW_INTENSITY\n#define NL_SHADOW_INTENSITY 1.0\n"
        
        if 'Disabled' in cloudType:
            new_config += "#undef NL_CLOUD_TYPE\n#define NL_CLOUD_TYPE 0\n#undef NL_CLOUD0_OPACITY\n#define NL_CLOUD0_OPACITY 0.0\n"
        elif 'Box' in cloudType:
            new_config += "#undef NL_CLOUD_TYPE\n#define NL_CLOUD_TYPE 0\n"
            
        content = content.rstrip()
        if content.endswith('#endif'):
            content = content[:-6] + new_config + "\n#endif\n"
        
        with open(config_path, 'w') as f:
            f.write(content)
            
        # Compile
        subprocess.run(['./build.sh', 'pack'], cwd=workspace_dir, check=True)
            
        # Find the generated mcpack
        build_dir = os.path.join(workspace_dir, 'build')
        mcpack_file = None
        for f in os.listdir(build_dir):
            if f.endswith('.mcpack'):
                mcpack_file = os.path.join(build_dir, f)
                break
                
        if not mcpack_file:
            raise Exception("Failed to find generated mcpack")
            
        # Read the file into memory so we can delete the folder before returning
        with open(mcpack_file, 'rb') as f:
            file_data = f.read()
            
        return send_file(
            io.BytesIO(file_data),
            as_attachment=True,
            download_name='Piglix_Classic_Bin.mcpack',
            mimetype='application/zip'
        )
        
    except Exception as e:
        return {"error": str(e)}, 500
    finally:
        # Cleanup: Delete the temporary workspace so server doesn't run out of storage!
        if os.path.exists(workspace_dir):
            shutil.rmtree(workspace_dir)

if __name__ == '__main__':
    # host='0.0.0.0' allows external connections if you host it
    app.run(port=5001, host='0.0.0.0')
