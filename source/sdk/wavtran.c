/******************************************************************************
*
* Copyright (C) 2009 - 2014 Xilinx, Inc.  All rights reserved.
*
* Permission is hereby granted, free of charge, to any person obtaining a copy
* of this software and associated documentation files (the "Software"), to deal
* in the Software without restriction, including without limitation the rights
* to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
* copies of the Software, and to permit persons to whom the Software is
* furnished to do so, subject to the following conditions:
*
* The above copyright notice and this permission notice shall be included in
* all copies or substantial portions of the Software.
*
* Use of the Software is limited solely to applications:
* (a) running on a Xilinx device, or
* (b) that interact with a Xilinx device through a bus or interconnect.
*
* THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
* IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
* FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
* XILINX  BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
* WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF
* OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
* SOFTWARE.
*
* Except as contained in this notice, the name of the Xilinx shall not be used
* in advertising or otherwise to promote the sale, use or other dealings in
* this Software without prior written authorization from Xilinx.
*
******************************************************************************/

/*
 * helloworld.c: simple test application
 *
 * This application configures UART 16550 to baud rate 9600.
 * PS7 UART (Zynq) is not initialized by this application, since
 * bootrom/bsp configures it to baud rate 115200
 *
 * ------------------------------------------------
 * | UART TYPE   BAUD RATE                        |
 * ------------------------------------------------
 *   uartns550   9600
 *   uartlite    Configurable only in HW design
 *   ps7_uart    115200 (configured by bootrom/bsp)
 */

#include <stdio.h>
#include "platform.h"
#include "xil_printf.h"
#include "ff.h"
#include "xsdps.h"
#include "xparameters.h"
#include "xil_io.h"

#define BRAMA_ADDRESS 0x43C00000
#define BRAMB_ADDRESS 0x43C00004
#define GLOBALRESETN  0x43C00008
#define SIGAL_C       0x43C0000C

//wave文件头
typedef struct WaveHeader
{
    BYTE riff[4];             //资源交换文件标志
    DWORD size;               //从下个地址开始到文件结尾的字节数
    BYTE wave_flag[4];        //wave文件标识
    BYTE fmt[4];              //波形格式标识
    DWORD fmt_len;            //过滤字节(一般为00000010H)
    WORD tag;                //格式种类，值为1时，表示PCM线性编码
    WORD channels;           //通道数，单声道为1，双声道为2
    DWORD samp_freq;          //采样频率
    DWORD byte_rate;          //数据传输率 (每秒字节＝采样频率×每个样本字节数)
    WORD block_align;        //块对齐字节数 = channles * bit_samp / 8
    WORD bit_samp;           //bits per sample (又称量化位数)
} wave_header_t;


typedef struct WaveStruct
{
	FIL fp;                  //file pointer
    wave_header_t header;      //header
    char data_flag[4];        //数据标识符
    DWORD length;             //采样数据总数
    DWORD *pData;             //data
} wave_t;

wave_t wave;

static BYTE AllwavfileNum;//wav文件数目
static BYTE wnameindex = 0;//wav文件序
static char * messages = NULL;
char data[4] = "data";
static char wavfile[20][13];
int iswav(const char *p);
void WaveOpen(char *file);
WORD* GetWave(void);
void pr_data(void);

int main()
{

 	TCHAR *Path = "0:/";//定义根路径
	FATFS fatfs;
	DIR dirs;
	FILINFO fno;//文件结构
	FRESULT Res;//定义状态变量
	UINT NumBytesRead;
	UINT NumBytesRead1;
	UINT j=0, n=0;
	FIL fil;//文件标识
	char RIFF[4];

    init_platform();

    print("***Welcome to use Sigma-Delta MusicBox***\n\r");
    print("**************Author:Wangfule************\n\r");
    print("**************Date:2017/03***************\n\r");
    print("Reseting FPGAinn g...\n\r");
    Xil_Out32(GLOBALRESETN, 0);
    if(1){
		//根路径挂载操作
		Res = f_mount(&fatfs, Path, 0);
		if(Res == FR_NOT_READY)
		{
			while(Res)
			{
				Res = f_mount(&fatfs, Path, 0);
				print("Please insert microSD!!!\n\r");
			}
		}
		else if (Res != FR_OK) {
			messages = "Path cannot mount";
			goto exit_system;
		}
		print("Successfully to Mount Root Directory\n\r");

		Res = f_opendir(&dirs, Path);
		if(Res == FR_NOT_READY)
		{
			while(Res)
			{
				Res = f_opendir(&dirs, Path);
				print("Please insert microSD!!!\n\r");
			}
		}
		else if (Res != FR_OK) {
			messages = "Cannot open the directory";
			goto exit_system;
		}
		print("Successfully to Open Root Directory\n\r");
    }

    if(1)
    {
    	while(1)
		{
			Res = f_readdir(&dirs, &fno);
			if (Res != FR_OK) {
				messages = "Cannot read the directory";
				goto exit_system;
			}
			xil_printf("Scanning %s...\n\r", fno.fname);
			if(fno.fattrib ==AM_DIR)
			{
				xil_printf("%s is A Directory, Skip!\n\r", fno.fname);
				continue;
			}
			else if(!fno.fname[0])
			{
				print("Scan finished, Exitting...\n\r");
				break;
			}
			else if(iswav(fno.fname))
			{
				Res = f_open(&fil, fno.fname, FA_READ);
				if(Res == FR_INVALID_NAME)
				{
					print("INVALID_NAME, skipping...\n\r");
					continue;
				}
				else if (Res) {
					messages = "Cannot open the file";
					goto exit_system;
				}
				Res = f_lseek(&fil, 0);
//				Res = f_read(&fil, (void*)RIFF, 4, &NumBytesRead);
//				if (Res) {
//					messages = "Failed to read RIFF";
//					f_close(&fil);
//					goto exit_system;
//				}
				Res = f_read(&fil, (void*)&wave.header, sizeof(wave_header_t),&NumBytesRead1);
				if (Res) {
					messages = "Failed to read WAVE header!!!";
					f_close(&fil);
					goto exit_system;
				}
				/*
				 * Close file.
				 */
				f_close(&fil);

				if(NumBytesRead1 == sizeof(wave_header_t) && wave.header.tag == 1 && wave.header.samp_freq == 44100 && wave.header.fmt[0] == 'f' &&  wave.header.fmt[1] == 'm' && wave.header.fmt[2] == 't' &&  wave.header.fmt[3] == ' ' && wave.header.riff[3]=='F' && wave.header.riff[2]=='F' && wave.header.riff[1]=='I' && wave.header.riff[0]=='R')
				{
					while(fno.fname[j])
					{
						wavfile[n][j] = fno.fname[j];
						j = j+1;
					}

					wavfile[n][j+1]=0;
					n ++;
					j = 0;
					xil_printf("Scanned a WAV file: %s\n\r", fno.fname);
				}
				else
				{
					xil_printf("%s is not a WAV file! skipped\n\r", fno.fname);
				}

				if(n == 20)
				{
					print("Scan finished, Exitting...\n\r");
					break;
				}
			}
		}
    	f_closedir(&dirs);
		AllwavfileNum = n;
    	xil_printf("Scanned %d wav files\n\r", AllwavfileNum);
    }

    if(AllwavfileNum == 0)
    {
    	while(1)
    	{
    		print("No wav files fitting!!!\n\r");
    	}
    }
    pr_data();

    exit_system:
	while(1)
		xil_printf("%s\n\r", messages);

    cleanup_platform();
    return 0;
}

int iswav(const char *p)
{
	int i = 0;
	for(i = 0; i < 10; i ++)
	{
		if(((*(p+i)) == '.') && ((*(p+i+1) == 'w')||(*(p+i+1) == 'W')) && ((*(p+i+2) == 'a')||(*(p+i+2) == 'A')) && ((*(p+i+3) == 'v')||(*(p+i+3) == 'V')) && ((*(p+i+4)) == 0))
		{
			return 1;
		}

	}
	return 0;
}

/*
 * open *.wav file
 */
void WaveOpen(char *file)
{
	FRESULT Res;   //状态变量
	UINT NumBytesRead;
	char tmpdata = 0;
	char *channel_mappings[] = {NULL,"mono","stereo"};
	DWORD total_time = 0;
	struct PlayTime        //播放时间
	{
		BYTE hour;
		BYTE minute;
		BYTE second;
	} play_time;

	Res = f_open(&wave.fp, file, FA_READ);
	if (Res) {
		messages = "Cannot open file";
		return;
	}

	Res = f_lseek(&wave.fp, 0);
	if (Res) {
		return;
	}
	Res = f_read(&wave.fp, (void*)&wave.header, sizeof(wave_header_t),&NumBytesRead);
	if (Res) {
		print("read head infomation!\n");
		return;
	}

    /* jump to "data" for reading data */
	do
	{
		Res = f_read(&wave.fp, (void*)&tmpdata, sizeof(char),&NumBytesRead);
		if (Res) {
			return;
		}
	}
	while('d' != tmpdata);
	wave.data_flag[0] = tmpdata;

	if(FR_OK != f_read(&wave.fp, (void*)&wave.data_flag[1], 3*sizeof(BYTE),&NumBytesRead))             /* data chunk */
	{
		print("read header data error!\n");
		return;
	}
	if(FR_OK != f_read(&wave.fp, (void*)&wave.length, sizeof(DWORD),&NumBytesRead))                 /* data chunk */
	{
		print("read length error!\n");
	}

	/* jduge data chunk flag */
	if(!strcmp(wave.data_flag, data))
	{
		printf("error : cannot read data!\n");
		return;
	}

	total_time = wave.length / wave.header.byte_rate;
	play_time.hour = (BYTE)(total_time / 3600);
	play_time.minute = (BYTE)((total_time / 60) % 60);
	play_time.second = (BYTE)(total_time % 60);
	/* printf file header information */
	xil_printf("%s %dHz %dbit, DataLen: %d, Rate: %d, Length: %2d:%2d:%2d\n\r",
		   channel_mappings[wave.header.channels],             //声道
		   wave.header.samp_freq,                              //采样频率
		   wave.header.bit_samp,                               //每个采样点的量化位数
           wave.length,
		   wave.header.byte_rate,
		   play_time.hour,play_time.minute,play_time.second);

}

/*
 * get wave data
 */
WORD* GetWave(void)
{
	FRESULT Res;   //状态变量
	UINT NumBytesRead;
	static WORD buffer[2048] = {0};
	DWORD n = wave.header.channels*1024;
	WORD p = 0;

	Res = f_read(&wave.fp, (void*)buffer, n*sizeof(WORD),&NumBytesRead);
	if(FR_OK != Res)             /* data chunk */
	{
		xil_printf("wav data read failed\n\r");
	}

	if(NumBytesRead < n*2)
	{
		p = NumBytesRead;
		for(; p<n; p++)
		{
			buffer[p] = 0;
		}
		f_close(&wave.fp);
		wnameindex = (wnameindex==AllwavfileNum-1)?0:(wnameindex + 1) ;
		xil_printf("Openning %s \n\r", wavfile[wnameindex]);
		WaveOpen(wavfile[wnameindex]);
		//xil_printf("FileSize:%d\n\r", file_size(&wave.fp));
	}

	return buffer;
}

void pr_data(void)
{
	static int Globalcounter = 0;    //记录wav文件读取行数
	int outsig_counter = 0;
	FRESULT Res;
	FIL fp;
    int num =0 ;					//定义计数
    WORD tmpdata;                   //临时缓存
    UINT wnum;
    int flag =0;                    //定义输入地址最高位
    int old_flag=0;                 //定义输入地址最高位的前态
    int old_flago=0;                //定义outsig地址最高位
    int flago=0;                    //定义outsig地址最高位的前态

    WORD *p1=NULL;
    xil_printf("Openning %s \n\r", wavfile[wnameindex]);
    WaveOpen(wavfile[wnameindex]);
    p1 = GetWave();
//    Res=f_open(&fp, "0:outsig.txt", FA_CREATE_ALWAYS|FA_WRITE | FA_READ);
//    if(FR_OK != Res)
//    {
//    	xil_printf("Cannot build failed outsig.txt, Error type:%d\n\r", Res);
//    }
//    f_close(&fp);
    for( num=0; num<1024; num=num+1 )
    {
    	tmpdata = p1[2*num];
    	Xil_Out32(XPAR_AXI_BRAM_CTRL_0_S_AXI_BASEADDR + num*4, tmpdata);
    }

    for( num=0; num<1024; num=num+1 )
	{

		tmpdata = Xil_In32(XPAR_AXI_BRAM_CTRL_0_S_AXI_BASEADDR + num*4);
		if(tmpdata != p1[2*num])
		{
			xil_printf("%d:Send Data Failed!!!\n\r", Globalcounter);
		}
	}
    p1 = GetWave();
    for(num = 0 ; num<1024; num=num+1 )
    {
        tmpdata = p1[wave.header.channels*num];
        Xil_Out32(XPAR_AXI_BRAM_CTRL_0_S_AXI_BASEADDR + 4096 + num*4, tmpdata);
    }
    for( num=0; num<1024; num=num+1 )
	{

		tmpdata = Xil_In32(XPAR_AXI_BRAM_CTRL_0_S_AXI_BASEADDR + 1 * 1024 * 4 + num*4);
		if(tmpdata != p1[wave.header.channels*num])
		{
			xil_printf("%d:Send Data Failed!!!\n\r", Globalcounter);
		}
	}
    print("Starting FPGAing...\n\r");
    Xil_Out32(GLOBALRESETN, 0xFFFFFFFF);
	while(1)
	{
		old_flag=flag;
		old_flago= flago;
		flag = Xil_In32(BRAMA_ADDRESS)/1024;
		if(old_flag!=flag)
		{
			p1 = GetWave();
			for( num=0; num<1024; num=num+1 )
			{
				tmpdata = p1[wave.header.channels*num];
				Xil_Out32(XPAR_AXI_BRAM_CTRL_0_S_AXI_BASEADDR + old_flag * 1024 * 4 + num*4, tmpdata);
			}
			for( num=0; num<1024; num=num+1 )
			{

				tmpdata = Xil_In32(XPAR_AXI_BRAM_CTRL_0_S_AXI_BASEADDR + old_flag * 1024 * 4 + num*4);
				if(tmpdata != p1[wave.header.channels*num])
				{
					xil_printf("%d:Send Data Failed!!!\n\r", Globalcounter);
				}
			}
			Globalcounter ++;
		}
//		flago = Xil_In32(BRAMB_ADDRESS)/1024;
//		if(old_flago!=flago&&outsig_counter!=(-1))
//		{
//			Res=f_open(&fp, "0:outsig.txt", FA_OPEN_ALWAYS|FA_WRITE| FA_READ );
//			Res = f_lseek(&wave.fp, outsig_counter);
//			if (Res) {
//				return;
//			}
//			for( num=0; num<1024; num=num+1 )
//			{
//				tmpdata = Xil_In32(XPAR_AXI_BRAM_CTRL_1_S_AXI_BASEADDR + old_flago * 2048 + num*4);//need change
//				Res=f_write(&fp, (void *)&tmpdata, sizeof(WORD), &wnum);
//				if(FR_OK != Res)
//					xil_printf("Data write failed");
//			}
//			f_close(&fp);
//			if(outsig_counter == 13856808)
//			{
//				outsig_counter = -1;
//			}
//			else
//				outsig_counter = outsig_counter + 1024;
//
//		}
	}

}


