using SAP.Data.OData;
using SAP.Data.OData.Offline.Store;
using SAP.Data.OData.Store;
using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Runtime.InteropServices.WindowsRuntime;
using System.Text;
using System.Threading.Tasks;
using Windows.Foundation;
using Windows.Foundation.Collections;
using Windows.UI.Xaml;
using Windows.UI.Xaml.Controls;
using Windows.UI.Xaml.Controls.Primitives;
using Windows.UI.Xaml.Data;
using Windows.UI.Xaml.Input;
using Windows.UI.Xaml.Media;
using Windows.UI.Xaml.Media.Imaging;
using Windows.UI.Xaml.Navigation;

// The Blank Page item template is documented at https://go.microsoft.com/fwlink/?LinkId=402352&clcid=0x409

namespace DemoStream
{
    /// <summary>
    /// An empty page that can be used on its own or navigated to within a Frame.
    /// </summary>
    public sealed partial class MainPage : Page
    {
        private StoreOperator storeOperator = null;
        StoreListener listener = null;
        public MainPage()
        {
            this.InitializeComponent();
        }

        private async Task CopyUDBFiles()
        {
            await CopyFile("lodata.udb");
            await CopyFile("lodata.rq.udb");
        }

        /// <summary>
        /// Copy the udb file from installation location to the user local folder.
        /// </summary>
        /// <param name="fileName"></param>
        /// <returns></returns>
        private async Task CopyFile(string fileName)
        {
            var localFolder = Windows.Storage.ApplicationData.Current.LocalFolder;
            var existingFile = await localFolder.TryGetItemAsync(fileName);

            if (existingFile == null)
            {
                var folder = Windows.ApplicationModel.Package.Current.InstalledLocation;
                var file = await Windows.ApplicationModel.Package.Current.InstalledLocation.GetFileAsync(fileName);
                if (file != null)
                {
                    await file.CopyAsync(localFolder, fileName, Windows.Storage.NameCollisionOption.FailIfExists);
                }
            }
        }

        private async void OpenStoreAsync()
        {
            await CopyUDBFiles();

            if (storeOperator !=null)
            {
                storeOperator.CloseOfflineStore();
                storeOperator = null;
            }

            storeOperator = new StoreOperator();
            storeOperator.result = this.Result;
            Dictionary<string, string> definingRequests = new Dictionary<string, string>
            {
                {"Photos", "/Photos"}
            };

            ODataOfflineStoreOptions options = new ODataOfflineStoreOptions
            {
                StoreName = "lodata",
                ServiceRoot = "http://localhost:8180/odata/Album/",
                Host = "http://localhost",
                Port = 8180
            };

            listener = new StoreListener(this.Status);
            await storeOperator.OpenOfflineStore(options, definingRequests, listener);
            await showEntityAsync();
        }

        private void CloseStore()
        {
            if (storeOperator != null)
            {
                storeOperator.CloseOfflineStore();
                storeOperator = null;
            }
        }

        private void Open_Click(object sender, RoutedEventArgs e)
        {
            OpenStoreAsync();
        }

        private void Close_Click(object sender, RoutedEventArgs e)
        {
            CloseStore();
        }

        private async void Create_Click(object sender, RoutedEventArgs e)
        {
            if (storeOperator != null)
            {
                await storeOperator.CreateStreamEntity();
                await showEntityAsync();
            }
        }

        private async void Update_Click(object sender, RoutedEventArgs e)
        {
            if (storeOperator != null)
            {
                IODataEntity entity = await storeOperator.QueryTheLastEntity();
                if (entity != null)
                {
                    await storeOperator.UpdateStreamEntity(entity);
                    await showEntityAsync();
                }
            }
        }

        private async void Delete_ClickAsync(object sender, RoutedEventArgs e)
        {
            if (storeOperator != null)
            {
                IODataEntity entity = await storeOperator.QueryTheLastEntity();
                if (entity != null)
                {
                    await storeOperator.DeleteStreamEntity(entity);
                    await showEntityAsync();
                }
            }
        }

        private async Task showEntityAsync()
        {
            if (storeOperator != null)
            {
                IODataEntity entity = await storeOperator.QueryTheLastEntity();
                if (entity != null)
                {
                    var resp = await storeOperator.GetStreamFromEntity(entity);

                    MemoryStream ms = new MemoryStream();
                    resp.InputStream.CopyTo(ms);
                    var stream = ms.AsRandomAccessStream();
                    stream.Seek(0);

                    var image = new BitmapImage();
                    image.SetSource(stream);
                    this.ImageBox.Source = image;
                }
                else
                {
                    this.ImageBox.Source = null;
                }
            }
        }
    }
}
