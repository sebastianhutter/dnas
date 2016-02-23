# -*- mode: python -*-

block_cipher = None


a = Analysis(['ldd_searcher.py'],
             pathex=['/home/shutter/Repository/dnas/scripts/helper-scripts/ldd_searcher'],
             binaries=None,
             datas=None,
             hiddenimports=[],
             hookspath=[],
             runtime_hooks=[],
             excludes=[],
             win_no_prefer_redirects=False,
             win_private_assemblies=False,
             cipher=block_cipher)
pyz = PYZ(a.pure, a.zipped_data,
             cipher=block_cipher)
exe = EXE(pyz,
          a.scripts,
          a.binaries,
          a.zipfiles,
          a.datas,
          name='ldd_searcher',
          debug=False,
          strip=False,
          upx=True,
          console=True )
