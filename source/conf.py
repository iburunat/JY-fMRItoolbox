# -*- coding: utf-8 -*-
import os
import sys

# -- Path setup --------------------------------------------------------------
# If you need to include Python modules (optional)
# sys.path.insert(0, os.path.abspath('.'))

# -- Project information -----------------------------------------------------
project = 'JY-fMRItoolbox'
author = 'Iballa Burunat'
copyright = 'JY-fMRItoolbox · © 2026, Iballa Burunat · MIT License'
# JY-fMRItoolbox · © 2026, Iballa Burunat · MIT License
version = '1.0'
release = '1.0.0'
language = 'en'

# -- General configuration ---------------------------------------------------
extensions = []
templates_path = ['_templates']
exclude_patterns = ['_build', '**.ipynb_checkpoints']
source_suffix = '.rst'
master_doc = 'index'
pygments_style = 'sphinx' # affects only code blocks highlighting
todo_include_todos = False

# -- Options for HTML output -------------------------------------------------
html_theme = 'sphinx_rtd_theme' # classic theme
html_css_files = ['jyu.css']
#html_theme = 'furo'             # nice theme
#html_theme = "pydata_sphinx_theme"
#html_theme = 'jyfmrtheme'
#html_theme = 'cloud'
#html_theme = 'groundwork'
# html_theme_path = [os.path.abspath('source/_themes/')]

# -- Theme options for Alabaster -------------------------------------------
# html_theme = 'alabaster'
# html_sidebars = {
#      '**': [
#          'about.html',
#          'navigation.html',
#          'relations.html',
#          'searchbox.html',
#      ]
#  }

# -- Theme options for Alabaster + others --------------------------------------
html_theme_options = {
    # Show the logo in the sidebar About block
    #'logo': 'JY-fMRItoolbox_logo.jpg',  # path relative to _static
    'logo_name': True,                  # also show project name next to logo
    'description': 'MATLAB toolbox for fMRI analysis and visualisation',
    #'sidebar_width': '260px',
    #'page_width': '960px',
    'show_related': True,  # shows "relations.html" content
    'show_powered_by': False,
    'navigation_depth': 4,
    'collapse_navigation': True,
    'sticky_navigation': True,
    'titles_only': False,  
    "sidebar_hide_name": False,
    "navigation_with_keys": True,
    # You can keep other Alabaster options as needed
    'github_user': 'iburunat',
    'github_repo': 'JY-fMRItoolbox',
}

# About block content
html_context = {
    'description': 'Documentation for JY-fMRItoolbox: a MATLAB toolbox for fMRI preprocessing and analysis.',
    # Optional: add a logo if you have one
    # 'logo': 'logo.png',  # place logo.png in _static folder
}



html_static_path = ['_static']
html_logo = '_static/JY-fMRItoolbox_logo.jpg'
html_title = 'JY-fMRItoolbox Documentation' # Optional: set HTML title
# html_css_files = ['custom2.css']  # optional overrides

# -- Options for other outputs ----------------------------------------------
latex_elements = {}
latex_documents = [
    (master_doc, 'JY-fMRItoolbox.tex', 'JY-fMRItoolbox Documentation',
     author, 'manual'),
]

man_pages = [
    (master_doc, 'jy-fmrtoolbox', 'JY-fMRItoolbox Documentation',
     [author], 1)
]

texinfo_documents = [
    (master_doc, 'JY-fMRItoolbox', 'JY-fMRItoolbox Documentation',
     author, 'JY-fMRItoolbox', 'MATLAB fMRI Toolbox.',
     'Miscellaneous'),
]

#-----#-----#-----#-----#-----#-----#-----#-----#-----
# html_theme = 'custom_rtd'
# html_theme_path = ['_themes']

# #html_logo = '_static/my_logo.png'
# #html_favicon = '_static/my_logo.png'
# html_static_path = ['_static']
# html_css_files = ['custom_colors.css']

# # Title
# html_title = 'JY-fMRItoolbox Documentation'
# #-----#-----#-----#-----#-----#-----#-----#-----#-----
epub_title = project
epub_author = author
epub_publisher = author
epub_copyright = copyright
epub_exclude_files = ['search.html']