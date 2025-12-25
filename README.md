# 🚀 SonarQube Auto Setup - เริ่มใช้งานใน 2 นาที!

SonarQube แบบอัตโนมัติ 100% สำหรับตรวจสอบคุณภาพและความปลอดภัยของโค้ด

> **⚡ ใช้งานง่ายสุดๆ**: แค่ git clone ไปวางในโปรเจค → แก้ชื่อโปรเจค → รันคำสั่งเดียว!

---

## 📋 สิ่งที่ต้องเตรียม

### 1. ติดตั้ง Docker Desktop

**Windows:**
1. ดาวน์โหลด Docker Desktop: https://www.docker.com/products/docker-desktop/
2. รันไฟล์ติดตั้ง `Docker Desktop Installer.exe`
3. ทำตามขั้นตอนการติดตั้ง (ใช้ค่า default ได้)
4. รีสตาร์ทเครื่อง (ถ้าขึ้นให้รีสตาร์ท)
5. เปิด Docker Desktop และรอให้ status เป็น "Running" (สีเขียว)

**ตรวจสอบว่าติดตั้งสำเร็จ:**
```powershell
# เปิด PowerShell แล้วรัน
docker --version
# ควรแสดงผล: Docker version 24.x.x หรือสูงกว่า
```

### 2. ตั้งค่า PowerShell (ครั้งเดียว)

```powershell
# เปิด PowerShell แบบ Administrator แล้วรัน
Set-ExecutionPolicy RemoteSigned -Scope CurrentUser

# กด Y เพื่อยืนยัน
```

### ✅ พร้อมแล้ว!
- ✅ Docker Desktop ติดตั้งแล้ว และเปิดอยู่
- ✅ PowerShell ตั้งค่าแล้ว
- ✅ RAM อย่างน้อย 4GB (แนะนำ 8GB)

---

## 🎯 วิธีใช้งาน (3 ขั้นตอน)

### 1️⃣ Clone SonarQube มาวางในโปรเจคของคุณ

```powershell
# เข้าไปที่โปรเจคของคุณ
cd C:\path\to\your-project

# Clone SonarQube setup
git clone <sonarqube-repo-url> sonarqube

# โครงสร้างจะเป็นแบบนี้:
# your-project/
# ├── sonarqube/           ← SonarQube setup
# ├── src/
# ├── package.json
# └── ...
```

### 2️⃣ สร้างไฟล์ `sonar-project.properties` ที่ root ของโปรเจค

```powershell
# คัดลอก template
copy sonarqube\sonar-project.properties.template sonar-project.properties

# แก้ไขแค่ 2 บรรทัด:
# sonar.projectKey=your-project-name
# sonar.projectName=Your Project Name
```

**ตัวอย่าง `sonar-project.properties`:**
```properties
sonar.projectKey=my-shop
sonar.projectName=My Shop Project
sonar.projectVersion=1.0

sonar.sources=.
sonar.sourceEncoding=UTF-8
sonar.exclusions=**/node_modules/**, **/dist/**, **/sonarqube/**
sonar.qualitygate.wait=true
sonar.host.url=http://localhost:9000
```

### 3️⃣ รันคำสั่งเดียวจบ!

```powershell
# ต้องเปิด Docker Desktop ก่อนนะ!

# รันคำสั่งนี้ที่ root ของโปรเจค
.\sonarqube\sonar.ps1 scan

# สคริปต์จะ:
# ✅ เช็คว่า Docker รันอยู่ไหม
# ✅ เริ่ม SonarQube อัตโนมัติ (ถ้ายังไม่ได้เริ่ม)
# ✅ รอให้ SonarQube พร้อม
# ✅ เปลี่ยน password (admin/admin → Admin@123456)
# ✅ สร้าง authentication token
# ✅ สแกนโค้ดทั้งหมด
# ✅ แสดงผลว่า Quality Gate PASS หรือ FAIL
```

**เสร็จแล้ว!** ดูผลได้ที่: http://localhost:9000

---

## 📝 คำสั่งทั้งหมด

เรียกใช้จากโฟลเดอร์โปรเจคหลัก:

| คำสั่ง | คำอธิบาย |
|--------|----------|
| `.\sonarqube\sonar.ps1 scan` | **สแกนโค้ด** (Auto ทุกอย่าง!) |
| `.\sonarqube\sonar.ps1 start` | เริ่ม SonarQube |
| `.\sonarqube\sonar.ps1 stop` | หยุด SonarQube |
| `.\sonarqube\sonar.ps1 restart` | รีสตาร์ท |
| `.\sonarqube\sonar.ps1 status` | ดูสถานะ |
| `.\sonarqube\sonar.ps1 logs` | ดู logs |

---

## 📁 โครงสร้างโปรเจค

```
your-project/                        ← โปรเจคหลัก
├── sonarqube/                       ← Git clone มาวางตรงนี้
│   ├── sonar.ps1                   ← Script หลัก ⭐
│   ├── docker-compose.yml          
│   ├── README.md                    
│   └── ...
│
├── sonar-project.properties         ← สร้างไฟล์นี้ที่ root ⚙️
│
├── src/                             ← โค้ดของคุณ
├── backend/
├── frontend/
├── package.json
└── ...

# วิธีใช้งาน:
cd your-project
.\sonarqube\sonar.ps1 scan          ← รันจาก root ของโปรเจค
```

---

## 💡 ตัวอย่างการใช้งานจริง

### ตัวอย่าง 1: Next.js Project

```powershell
# โครงสร้าง:
my-nextjs-app/
├── sonarqube/
├── sonar-project.properties    # sonar.projectKey=my-nextjs-app
├── app/
├── components/
├── package.json
└── next.config.js

# รัน:
cd my-nextjs-app
.\sonarqube\sonar.ps1 scan
```

### ตัวอย่าง 2: FastAPI + Next.js (Monorepo)

```powershell
# โครงสร้าง:
my-fullstack-app/
├── sonarqube/
├── sonar-project.properties    # sonar.projectKey=fullstack-app
├── backend/                    # FastAPI
├── frontend/                   # Next.js
└── docker-compose.yml

# รัน:
cd my-fullstack-app
.\sonarqube\sonar.ps1 scan
# จะสแกนทั้ง backend และ frontend!
```

### ตัวอย่าง 3: Python Project

```powershell
# โครงสร้าง:
my-python-api/
├── sonarqube/
├── sonar-project.properties    # sonar.projectKey=python-api
├── app/
├── tests/
├── requirements.txt
└── main.py

# รัน:
cd my-python-api
.\sonarqube\sonar.ps1 scan
```

---

## 🔄 การสแกนหลายโปรเจค

### คำถาม: ถ้าสแกนโปรเจคที่ 1 แล้ว จะสแกนโปรเจคที่ 2 ต้องทำยังไง?

**คำตอบ**: ง่ายมาก! แค่แต่ละโปรเจคมี `sonar-project.properties` เป็นของตัวเอง และ `projectKey` ไม่ซ้ำกัน

### 📁 โครงสร้างที่แนะนำ:

```
workspace/
├── project-1/
│   ├── sonarqube/                    ← Clone ไว้ที่นี่
│   ├── sonar-project.properties      ← projectKey=project-1
│   └── src/
│
├── project-2/
│   ├── sonarqube/                    ← Clone ไว้ที่นี่
│   ├── sonar-project.properties      ← projectKey=project-2
│   └── backend/
│
└── project-3/
    ├── sonarqube/                    ← Clone ไว้ที่นี่
    ├── sonar-project.properties      ← projectKey=project-3
    └── ...
```

### 🎯 ขั้นตอนการสแกน:

#### 1️⃣ สแกนโปรเจคที่ 1
```powershell
cd C:\workspace\project-1

# สร้าง config (ครั้งแรก)
copy sonarqube\sonar-project.properties.template sonar-project.properties

# แก้ไข sonar-project.properties
# sonar.projectKey=project-1
# sonar.projectName=Project 1

# สแกน
.\sonarqube\sonar.ps1 scan
```

#### 2️⃣ สแกนโปรเจคที่ 2 (SonarQube ยังรันอยู่)
```powershell
cd C:\workspace\project-2

# สร้าง config (ครั้งแรก)
copy sonarqube\sonar-project.properties.template sonar-project.properties

# แก้ไข sonar-project.properties
# sonar.projectKey=project-2
# sonar.projectName=Project 2

# สแกนเลย! (ไม่ต้อง restart SonarQube)
.\sonarqube\sonar.ps1 scan
```

#### 3️⃣ สแกนโปรเจคที่ 3
```powershell
cd C:\workspace\project-3
# แก้ไข sonar-project.properties
# sonar.projectKey=project-3

.\sonarqube\sonar.ps1 scan
```

### ✅ สิ่งสำคัญ:

**ต้องทำ:**
- ✅ แต่ละโปรเจคต้องมี `sonar-project.properties` เป็นของตัวเอง
- ✅ `projectKey` ต้องไม่ซ้ำกัน (เช่น project-1, project-2, shop, api)
- ✅ SonarQube ต้องรันอยู่ (แต่เริ่มครั้งเดียวพอ)

**ไม่ต้องทำ:**
- ❌ ไม่ต้องหยุด SonarQube ระหว่างสแกน
- ❌ ไม่ต้อง restart SonarQube
- ❌ ไม่ต้องสร้าง token ใหม่
- ❌ ไม่ต้อง login ใหม่

### 📊 ดูผลใน SonarQube UI:

เข้า http://localhost:9000 จะเห็นโปรเจคทั้งหมด:

```
Projects
├── Project 1 (project-1)      ← Dashboard แยก
├── Project 2 (project-2)      ← Dashboard แยก
└── Project 3 (project-3)      ← Dashboard แยก
```

### 💡 วิธีอื่น: ใช้ SonarQube ตัวเดียวสำหรับหลายโปรเจค

```powershell
# ติดตั้ง SonarQube ไว้ที่เดียว
C:\sonarqube\

# แต่ละโปรเจคมีแค่ sonar-project.properties
C:\workspace\project-1\sonar-project.properties
C:\workspace\project-2\sonar-project.properties

# สแกนโดยเรียก script จากที่เดียว
cd C:\workspace\project-1
C:\sonarqube\sonar.ps1 scan

cd C:\workspace\project-2
C:\sonarqube\sonar.ps1 scan
```

**ข้อดี**: ประหยัดพื้นที่  
**ข้อเสีย**: ต้องจำ path ของ sonar.ps1


---

## 🔧 การตั้งค่า sonar-project.properties

### Template พื้นฐาน (คัดลอกได้เลย)

```properties
# แก้แค่ 2 บรรทัดนี้!
sonar.projectKey=YOUR-PROJECT-NAME
sonar.projectName=Your Project Display Name
sonar.projectVersion=1.0

# ส่วนที่เหลือไม่ต้องแก้
sonar.sources=.
sonar.sourceEncoding=UTF-8
sonar.exclusions=**/node_modules/**, **/dist/**, **/sonarqube/**, **/.next/**
sonar.qualitygate.wait=true
sonar.host.url=http://localhost:9000
```

### ตัวเลือกเพิ่มเติม (Optional)

```properties
# สำหรับโปรเจค JavaScript/TypeScript
sonar.javascript.lcov.reportPaths=coverage/lcov.info
sonar.typescript.tsconfigPath=tsconfig.json

# สำหรับโปรเจค Python
sonar.python.coverage.reportPaths=coverage.xml

# ระบุ test files
sonar.tests=tests
sonar.test.inclusions=**/*.test.js,**/*.spec.js

# Exclude เพิ่มเติม
sonar.exclusions=\
  **/node_modules/**,\
  **/dist/**,\
  **/sonarqube/**,\
  **/coverage/**,\
  **/*.test.js
```

---

## 🛠 Troubleshooting

### ❌ Script ไม่รัน (Execution Policy)

```powershell
# เปิด PowerShell แบบ Administrator
Set-ExecutionPolicy RemoteSigned -Scope CurrentUser
```

### ❌ Docker ไม่รัน

```powershell
# ต้องเปิด Docker Desktop ก่อน
# ตรวจสอบ:
docker ps
```

### ❌ Port 9000 ถูกใช้งาน

```powershell
# หา process ที่ใช้ port 9000
netstat -ano | findstr :9000

# หยุด process หรือแก้ไข sonarqube/docker-compose.yml
# เปลี่ยน "9000:9000" เป็น "9001:9000"
```

### ❌ ไม่พบ sonar-project.properties

```powershell
# ต้องสร้างไฟล์นี้ที่ root ของโปรเจค (ไม่ใช่ใน sonarqube/)
copy sonarqube\sonar-project.properties.template sonar-project.properties

# แล้วแก้ไขชื่อโปรเจค
```

### ❌ Scanner ไม่พบ sonarqube network

```powershell
# ต้องเริ่ม SonarQube ก่อน
.\sonarqube\sonar.ps1 start

# รอ 1-2 นาที แล้วค่อย scan
.\sonarqube\sonar.ps1 scan
```

---

## ⚙️ การตั้งค่าเพิ่มเติม

### เปลี่ยน Password (ถ้าต้องการ)

```powershell
# Login: http://localhost:9000
# Username: admin
# Password: Admin@123456  (ถ้า auto-auth เปลี่ยนแล้ว)
#          admin          (ถ้ายังไม่ได้เปลี่ยน)

# ไปที่ My Account → Security → Change Password
```

### สร้าง Token เอง (ถ้าไม่ใช้ auto-auth)

```powershell
# 1. Login http://localhost:9000
# 2. My Account → Security → Generate Token
# 3. คัดลอก token แล้วใช้:

.\sonarqube\sonar.ps1 scan -Token "squ_your-token-here"
```

### ตั้งค่า Quality Gates

```powershell
# 1. เข้า http://localhost:9000
# 2. ไปที่ Quality Gates
# 3. สร้าง/แก้ไข gates ตามต้องการ
# 4. Set as Default
```

---

## 📊 ดูผลลัพธ์

### Web UI
- URL: **http://localhost:9000**
- Login: `admin` / `Admin@123456`

### Dashboard
- **Overview**: ดูสถานะโดยรวม
- **Issues**: ดู Bugs, Vulnerabilities, Code Smells
- **Measures**: ดู Metrics ต่างๆ
- **Code**: ดู code ที่มีปัญหา

---

## 🎯 Best Practices

1. **Scan ก่อน Commit**: รัน scan ก่อน git push
2. **ตั้ง Quality Gate**: กำหนดเกณฑ์ที่เหมาะสม
3. **Fix Issues**: แก้ไข Critical และ High issues ก่อน
4. **Regular Scans**: Scan เป็นประจำ
5. **CI/CD Integration**: ผสาน scan เข้า pipeline

---

## 🚀 Next Steps

### 1. ผสานใน CI/CD

**GitHub Actions:**
```yaml
- name: SonarQube Scan
  run: |
    .\sonarqube\sonar.ps1 scan -Token ${{ secrets.SONAR_TOKEN }}
```

### 2. ตั้งค่า Pre-commit Hook

```powershell
# .git/hooks/pre-commit
.\sonarqube\sonar.ps1 scan
```

### 3. สแกนหลายโปรเจค

แต่ละโปรเจคมี sonar-project.properties เป็นของตัวเอง:

```
workspace/
├── project-a/
│   ├── sonarqube/
│   └── sonar-project.properties  # projectKey=project-a
├── project-b/
│   ├── sonarqube/
│   └── sonar-project.properties  # projectKey=project-b
└── project-c/
    ├── sonarqube/
    └── sonar-project.properties  # projectKey=project-c
```

---

## 📞 Support

- 📚 [SonarQube Docs](https://docs.sonarqube.org/latest/)
- 💬 [Community](https://community.sonarsource.com/)
- 🐳 [Docker Hub](https://hub.docker.com/_/sonarqube)

---

## ✨ Features

- ✅ **Zero Configuration**: Clone → Edit Name → Scan!
- ✅ **Auto Everything**: Start, Auth, Token, Scan
- ✅ **One Command**: `.\sonarqube\sonar.ps1 scan`
- ✅ **Quality Gate**: Pass/Fail ทันที
- ✅ **Multi-Project**: รองรับหลายโปรเจค
- ✅ **Production Ready**: PostgreSQL + Volumes
- ✅ **Developer Friendly**: ชัดเจน ง่าย รวดเร็ว

---

**🎉 Happy Scanning!**

**เวอร์ชัน**: Auto Setup v2.0 (Git Clone Edition)  
**อัพเดทล่าสุด**: 2025-12-25