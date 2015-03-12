﻿using System.Windows.Forms;

namespace MW5.Services.Services.Abstract
{
    public interface IFileDialogService
    {
        bool SaveFile(string filter, out string filename);
        bool Open(string filter, out string filename);
        bool OpenFile(DataSourceType layerType, out string filename);
        bool OpenFiles(DataSourceType layerType, out string[] filenames);
        bool ChooseFolder(string initialPath, out string chosenPath);
    }
}