using SAP.Data.OData;
using SAP.Data.OData.Offline.Store;
using SAP.Data.OData.Store;
using SAP.Net.Http;
using System;
using System.Collections.Generic;
using System.Diagnostics;
using System.Linq;
using System.Text;
using System.Threading;
using System.Threading.Tasks;
using Windows.UI.Xaml.Controls;
using Windows.Storage.Streams;

namespace DemoStream
{
    class StoreOperator
    {
        public ODataOfflineStore Store { get; set;}
        private StoreListener listener = null;
        public TextBlock result { private get; set; }


        public async Task<bool> OpenOfflineStore(ODataOfflineStoreOptions options, Dictionary<string, string> definingRequests, StoreListener listener)
        {
            this.listener = listener;

            CloseOfflineStore();
            Store = new ODataOfflineStore();

            foreach (String key in definingRequests.Keys)
            {
                options.AddDefiningRequest(key, definingRequests[key], false);
            }


            try
            {
                ODataOfflineStore.GlobalInit();
                await Store.OpenStoreAsync(options, listener.CancelToken.Token, listener);
                var meta = Store.Metadata.GetMetaEntity("Album.Photos");
                return true;
            }
            catch (Exception ex)
            {
                result.Text += ex.Message + "\n";
                return false;
            }
        }

        public void CloseOfflineStore()
        {
            if (Store != null)
            {
                Store.CloseStore();
                Store = null;
                listener = null;
            }
        }

        public async Task<IODataResponse> QueryOfflineStore(string entitySet)
        {
            if (Store == null)
            {
                return null;
            }

            IODataRequestExecution exec = Store.ScheduleReadEntitySet(entitySet);
            return await exec.Response;
        }

        private async Task<int> QueryEntityCount(string entitySet)
        {
            if (Store == null)
            {
                return -1;
            }

            ODataRequestParametersSingle requestParameters = new ODataRequestParametersSingle(entitySet + "/$count");
            IODataRequestExecution exec = Store.ScheduleRequest(requestParameters);
            await exec.Response;
            ODataRawValue rawValue = (ODataRawValue)((IODataResponseSingle)exec.Response.Result).Payload;

            return Int32.Parse(rawValue.Value);
        }

        /// <summary>
        /// While creating a media entity, we could only post with its binary media resource. 
        /// If we want to add values to its non-media properties, we need to to update/patch the entity 
        /// instance with those property values.
        /// </summary>
        /// <returns></returns>
        private async Task UpdateNonMediaProperty(IODataEntity entity, string value)
        {
            string keyProeprtyName = "pk";
            string propertyName = "title";

            // We do not update the key property. Only remains those proeprties to be updated.
            entity.Properties.Remove(keyProeprtyName);

            var prop = new ODataProperty(propertyName);
            prop.Value = value;
            entity.Properties[propertyName] = prop;
            var req = new ODataRequestParametersSingle(entity.EditResourcePath, RequestMode.Update, entity);
            req.Etag = entity.Etag;

            try
            {
                var exec = Store.ScheduleRequest(req);
                await exec.Response;
            }
            catch (Exception ex)
            {
                result.Text += ex.Message + "\n";
            }
        }

        /// <summary>
        /// Get the last entity
        /// </summary>
        /// <returns></returns>
        public async Task<IODataEntity> QueryTheLastEntity()
        {
            IODataEntity ent = null;
            int count = await QueryEntityCount("Photos");
            result.Text += string.Format("Total Count: {0}", count) + "\n";

            StringBuilder builder = new StringBuilder();
            IODataResponse response = await QueryOfflineStore("Photos");
            IODataEntitySet entitySet = (IODataEntitySet)((IODataResponseSingle)response).Payload;
            foreach (IODataEntity entity in entitySet)
            {
                ent = entity;
            }

            // Display the title of the current entity.
            if (ent != null)
            {
                string propertyName = "title";
                string propertyValue = (string)ent.Properties[propertyName].Value;
                result.Text += string.Format("Property {0} = {1}", propertyName, propertyValue) + "\n";
            }

            return ent;
        }

        public async Task<IODataEntity> CreateStreamEntity()
        {
            var stream = await pickAPicture();
            if (stream == null)
            {
                return null;
            }

            Windows.Storage.Streams.Buffer buffer = new Windows.Storage.Streams.Buffer((uint)stream.Size);
            await stream.ReadAsync(buffer, (uint)stream.Size, InputStreamOptions.None);
            DataReader dataReader = DataReader.FromBuffer(buffer);
            byte[] bytes = new byte[buffer.Length];
            dataReader.ReadBytes(bytes);

            ODataRequestParametersSingle req;
            IODataResponse resp;
            IODataRequestExecution exec;

            req = new ODataRequestParametersSingle("Photos", RequestMode.Create, new ODataUploadMediaResource(bytes, stream.ContentType));

            try
            {
                exec = Store.ScheduleRequest(req);
                resp = await exec.Response;
            }
            catch (Exception ex)
            {
                result.Text += ex.Message + "\n";
                return null;
            }

            if (((ODataResponseSingle)resp).PayloadType == ODataType.Error)
            {
                return null;
            }
            else
            {
                ODataEntity entity = (ODataEntity)((ODataResponseSingle)resp).Payload;
                await UpdateNonMediaProperty(entity, "Added at: " + DateTime.Now.ToString());
                return entity;
            }

        }

        public async Task<bool> UpdateStreamEntity(IODataEntity mediaEntity)
        {
            var stream = await pickAPicture();
            if (stream == null)
            {
                return false;
            }

            Windows.Storage.Streams.Buffer buffer = new Windows.Storage.Streams.Buffer((uint)stream.Size);
            await stream.ReadAsync(buffer, (uint)stream.Size, InputStreamOptions.None);
            DataReader dataReader = DataReader.FromBuffer(buffer);
            byte[] bytes = new byte[buffer.Length];
            dataReader.ReadBytes(bytes);

            ODataRequestParametersSingle req;
            IODataResponse resp;
            IODataRequestExecution exec;

            req = new ODataRequestParametersSingle(mediaEntity.EditMediaLink.ToString(), RequestMode.Update, new ODataUploadMediaResource(bytes, stream.ContentType));
            req.Etag = mediaEntity.MediaEtag;

            try
            {
                exec = Store.ScheduleRequest(req);
                resp = await exec.Response;
                await UpdateNonMediaProperty(mediaEntity, "Updated at: " + DateTime.Now.ToString());
                return true;
            }
            catch (Exception ex)
            {
                result.Text += ex.Message + "\n";
                return false;
            }
        }

        public async Task<bool> DeleteStreamEntity(IODataEntity mediaEntity)
        {
            ODataRequestParametersSingle req;
            IODataResponse resp;
            IODataRequestExecution exec;

            req = new ODataRequestParametersSingle(mediaEntity.EditResourcePath, RequestMode.Delete, mediaEntity);

            try
            {
                exec = Store.ScheduleRequest(req);
                resp = await exec.Response;
                return true;
            }
            catch (Exception ex)
            {
                result.Text += ex.Message + "\n";
                return false;
            }
        }

        public async Task<IODataDownloadMediaResource> GetStreamFromEntity(IODataEntity mediaEntity)
        {
            IODataMediaRequestExecution exec;

            try
            {
                exec = Store.ScheduleReadMediaResource(mediaEntity.MediaLink);
                return await exec.Response;
            } catch (Exception ex)
            {
                result.Text += ex.Message + "\n";
                return null;
            }
        }

        public async Task<IRandomAccessStreamWithContentType> pickAPicture()
        {
            var picker = new Windows.Storage.Pickers.FileOpenPicker();
            picker.ViewMode = Windows.Storage.Pickers.PickerViewMode.Thumbnail;
            picker.SuggestedStartLocation = Windows.Storage.Pickers.PickerLocationId.PicturesLibrary;
            picker.FileTypeFilter.Add(".jpg");
            picker.FileTypeFilter.Add(".jpeg");
            picker.FileTypeFilter.Add(".png");

            Windows.Storage.StorageFile file = await picker.PickSingleFileAsync();
            if (file != null)
            {
                return await file.OpenReadAsync();
            }
            else
            {
                return null;
            }
        }
    }
    public class StoreListener : IProgress<StoreOpenStatus>, IProgress<ProgressStatus>
    {
        private TextBlock output = null;

        public StoreListener(TextBlock box)
        {
            output = box;
            CancelToken = new CancellationTokenSource();
        }


        public CancellationTokenSource CancelToken { get; set; }
        public void Report(ProgressStatus value)
        {
            output.Text = output.Text + "\n" + string.Format("{0}. Recv {1}, Send {2}", Enum.GetName(typeof(ProgressState), value.ProgressState), value.BytesRecv, value.BytesSent);
        }

        public void Report(StoreOpenStatus value)
        {
 /*           output.Text = output.Text + "\n" + string.Format("Store state: {0}", Enum.GetName(typeof(StoreOpenState), value.StoreOpenState));
            if (value.ProgressStatus != null)
            {
                var status = value.ProgressStatus;
                output.Text = output.Text + "\n" + string.Format("{0}. Recv {1}, Send {2}", Enum.GetName(typeof(ProgressState), status.ProgressState), status.BytesRecv, status.BytesSent);
            }*/
        }

    }
}
