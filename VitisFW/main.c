#include <stdio.h>
#include "xparameters.h"
#include "xuartlite_l.h"   /* low-level polled UART Lite driver */
#include "xil_io.h"
#include "xil_types.h"
 
#define UART_BASEADDR   XPAR_AXI_UARTLITE_0_BASEADDR
#define BRAM_BASEADDR   XPAR_AXI_BRAM_CTRL_0_BASEADDR
 
#define BRAM_SIZE_BYTES 32768u

static void drain_uart_rx(u32 *write_offset, u32 *bytes_received)
{
    while (!XUartLite_IsReceiveEmpty(UART_BASEADDR)) {
        u8 rx_byte = XUartLite_RecvByte(UART_BASEADDR);
 
        Xil_Out8(BRAM_BASEADDR + *write_offset, rx_byte);
        XUartLite_SendByte(UART_BASEADDR, rx_byte);
 
        *write_offset = (*write_offset + 1) % BRAM_SIZE_BYTES;
        (*bytes_received)++;
    }
}
 
int main(void)
{ 
    xil_printf("Urbana UART->BRAM ready (no heartbeat -- read BRAM directly to verify).\r\n");
 
    while (1) {
        drain_uart_rx(&write_offset, &bytes_received);
    }
 
    return 0;
}
