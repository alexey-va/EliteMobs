package com.magmaguy.elitemobs.utils;


import org.bukkit.inventory.ItemStack;
import org.bukkit.util.io.BukkitObjectInputStream;
import org.bukkit.util.io.BukkitObjectOutputStream;
import java.io.*;
import java.nio.charset.StandardCharsets;
import java.util.Base64;

public class ObjectSerializer {

    private ObjectSerializer() {
    }

    /**
     * Read the object from Base64 string.
     */
    public static Object fromString(String s) throws IOException,
            ClassNotFoundException {
        byte[] data = Base64.getDecoder().decode(s);
        repairLegacySerialVersionUIDs(data);
        ObjectInputStream ois = new ObjectInputStream(
                new ByteArrayInputStream(data));
        ois.setObjectInputFilter(ObjectSerializer::filterLegacyClass);
        Object o = ois.readObject();
        ois.close();
        return o;
    }

    /**
     * Old EliteMobs releases did not declare serialVersionUID on quest classes, so harmless source
     * changes made already-persisted rows unreadable. Rewrite only EliteMobs class descriptors to
     * their current UID before the one-time JSON migration; the stream's original field schema is
     * retained and Java's normal compatible-field mapping still applies.
     */
    private static void repairLegacySerialVersionUIDs(byte[] data) {
        for (int offset = 0; offset + 12 < data.length; offset++) {
            if (data[offset] != ObjectStreamConstants.TC_CLASSDESC) continue;
            int nameLength = (Byte.toUnsignedInt(data[offset + 1]) << 8) | Byte.toUnsignedInt(data[offset + 2]);
            int nameStart = offset + 3;
            int uidStart = nameStart + nameLength;
            if (nameLength < 1 || uidStart + Long.BYTES > data.length) continue;
            String className = new String(data, nameStart, nameLength, StandardCharsets.UTF_8);
            if (!className.startsWith("com.magmaguy.elitemobs.")) continue;
            try {
                Class<?> localClass = Class.forName(className, false, ObjectSerializer.class.getClassLoader());
                ObjectStreamClass descriptor = ObjectStreamClass.lookup(localClass);
                if (descriptor == null) continue;
                long uid = descriptor.getSerialVersionUID();
                for (int index = Long.BYTES - 1; index >= 0; index--) {
                    data[uidStart + index] = (byte) uid;
                    uid >>>= 8;
                }
                offset = uidStart + Long.BYTES - 1;
            } catch (ClassNotFoundException ignored) {
                // ObjectInputStream will report the unknown class with its normal actionable error.
            }
        }
    }

    private static ObjectInputFilter.Status filterLegacyClass(ObjectInputFilter.FilterInfo info) {
        if (info.depth() > 100 || info.references() > 100_000 || info.streamBytes() > 16_777_216)
            return ObjectInputFilter.Status.REJECTED;
        Class<?> type = info.serialClass();
        if (type == null) return ObjectInputFilter.Status.UNDECIDED;
        while (type.isArray()) type = type.getComponentType();
        if (type.isPrimitive()) return ObjectInputFilter.Status.ALLOWED;
        String name = type.getName();
        if (name.startsWith("com.magmaguy.elitemobs.") || name.startsWith("java.lang.")
                || name.startsWith("java.util.") || name.startsWith("org.bukkit."))
            return ObjectInputFilter.Status.ALLOWED;
        return ObjectInputFilter.Status.REJECTED;
    }

    /**
     * Write the object to a Base64 string.
     */
    public static String toString(Serializable o) throws IOException {
        ByteArrayOutputStream baos = new ByteArrayOutputStream();
        ObjectOutputStream oos = new ObjectOutputStream(baos);
        oos.writeObject(o);
        oos.close();
        return Base64.getEncoder().encodeToString(baos.toByteArray());
    }

    /**
     * A method to serialize an {@link ItemStack} array to Base64 String.
     * <p>
     * <p/>
     *
     * @param itemStack to turn into a Base64 String.
     * @return Base64 string of the items.
     * @throws IllegalStateException
     */
    public static String itemStackArrayToBase64(ItemStack itemStack) throws IllegalStateException {
        try {
            ByteArrayOutputStream outputStream = new ByteArrayOutputStream();
            BukkitObjectOutputStream dataOutput = new BukkitObjectOutputStream(outputStream);

            // Write the size of the inventory
            //dataOutput.writeInt(1);
            dataOutput.writeObject(itemStack);

            // Serialize that array
            dataOutput.close();
            return Base64.getMimeEncoder().encodeToString(outputStream.toByteArray());
        } catch (Exception e) {
            throw new IllegalStateException("Unable to save item stacks.", e);
        }
    }

    /**
     * Gets an array of ItemStacks from Base64 string.
     * <p>
     * <p/>
     *
     * @param data Base64 string to convert to ItemStack array.
     * @return ItemStack array created from the Base64 string.
     * @throws IOException
     */
    public static ItemStack itemStackArrayFromBase64(String data) throws IOException {
        try {
            ByteArrayInputStream inputStream = new ByteArrayInputStream(Base64.getMimeDecoder().decode(data));
            BukkitObjectInputStream dataInput = new BukkitObjectInputStream(inputStream);
            ItemStack itemStack = (ItemStack) dataInput.readObject();
            dataInput.close();
            return itemStack;
        } catch (ClassNotFoundException e) {
            throw new IOException("Unable to decode class type.", e);
        }
    }

}
